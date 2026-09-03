// Package internal exposes RunCLI, which is the entry point for the tester CLI.
package internal

import (
	"encoding/json"

	testerutils "github.com/codecrafters-io/tester-utils"
	"github.com/codecrafters-io/tester-utils/tester_context"
)

func RunCLI(env map[string]string) int {
	env = normalizedEnv(env)
	return testerutils.RunCLI(env, testerDefinition)
}

// normalizedEnv keeps the tester runnable outside the CodeCrafters platform.
// The platform normally supplies the list of cases to run, but this tester
// already knows every supported case. Fall back to that list when the optional
// platform context is absent or malformed.
func normalizedEnv(env map[string]string) map[string]string {
	normalized := make(map[string]string, len(env)+2)
	for key, value := range env {
		normalized[key] = value
	}

	if normalized["CODECRAFTERS_REPOSITORY_DIR"] == "" {
		normalized["CODECRAFTERS_REPOSITORY_DIR"] = normalized["CODECRAFTERS_SUBMISSION_DIR"]
	}

	var suppliedCases []tester_context.TesterContextTestCase
	if err := json.Unmarshal([]byte(normalized["CODECRAFTERS_TEST_CASES_JSON"]), &suppliedCases); err != nil || len(suppliedCases) == 0 {
		normalized["CODECRAFTERS_TEST_CASES_JSON"] = defaultTestCasesJSON()
	}

	return normalized
}

func defaultTestCasesJSON() string {
	cases := make([]tester_context.TesterContextTestCase, 0, len(testerDefinition.TestCases))
	for _, testCase := range testerDefinition.TestCases {
		cases = append(cases, tester_context.TesterContextTestCase{
			Slug:            testCase.Slug,
			TesterLogPrefix: testCase.Slug,
			Title:           testCase.Slug,
		})
	}

	encodedCases, err := json.Marshal(cases)
	if err != nil {
		panic("failed to encode built-in test cases: " + err.Error())
	}
	return string(encodedCases)
}
