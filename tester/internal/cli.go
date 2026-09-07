// Package internal exposes RunCLI, which is the entry point for the tester CLI.
package internal

import (
	_ "embed"
	"encoding/json"
	"fmt"
	"strings"

	testerutils "github.com/codecrafters-io/tester-utils"
	"github.com/codecrafters-io/tester-utils/tester_context"
	"gopkg.in/yaml.v3"
)

//go:embed test_helpers/course_definition.yml
var courseDefinitionYAML []byte

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
	} else {
		normalized["CODECRAFTERS_TEST_CASES_JSON"] = encodeTestCases(withReadableTitles(suppliedCases))
	}

	return normalized
}

func defaultTestCasesJSON() string {
	stageNames := stageNamesBySlug()
	cases := make([]tester_context.TesterContextTestCase, 0, len(testerDefinition.TestCases))
	for _, testCase := range testerDefinition.TestCases {
		title := stageTitle(testCase.Slug, stageNames)
		cases = append(cases, tester_context.TesterContextTestCase{
			Slug:            testCase.Slug,
			TesterLogPrefix: title,
			Title:           title,
		})
	}

	return encodeTestCases(cases)
}

func withReadableTitles(cases []tester_context.TesterContextTestCase) []tester_context.TesterContextTestCase {
	stageNames := stageNamesBySlug()
	readable := make([]tester_context.TesterContextTestCase, len(cases))
	for i, testCase := range cases {
		readable[i] = testCase
		name := stageTitle(testCase.Slug, stageNames)
		if testCase.Title == "" || testCase.Title == testCase.Slug {
			readable[i].Title = name
		}
		if !isFixtureStyleCase(testCase) {
			readable[i].TesterLogPrefix = name
		}
	}
	return readable
}

func isFixtureStyleCase(testCase tester_context.TesterContextTestCase) bool {
	expectedTitle := fmt.Sprintf("Stage #%s (%s)", strings.ToUpper(testCase.Slug), testCase.Slug)
	expectedPrefix := fmt.Sprintf("tester::#%s", strings.ToUpper(testCase.Slug))
	return testCase.Title == expectedTitle && strings.EqualFold(testCase.TesterLogPrefix, expectedPrefix)
}

func stageTitle(slug string, names map[string]string) string {
	if name := names[slug]; name != "" {
		return name
	}
	return slug
}

func encodeTestCases(cases []tester_context.TesterContextTestCase) string {
	encodedCases, err := json.Marshal(cases)
	if err != nil {
		panic("failed to encode built-in test cases: " + err.Error())
	}
	return string(encodedCases)
}

type courseYAML struct {
	Stages []struct {
		Slug string `yaml:"slug"`
		Name string `yaml:"name"`
	} `yaml:"stages"`
}

func stageNamesBySlug() map[string]string {
	var course courseYAML
	if err := yaml.Unmarshal(courseDefinitionYAML, &course); err != nil {
		panic("failed to parse embedded course definition: " + err.Error())
	}

	names := make(map[string]string, len(course.Stages))
	for _, stage := range course.Stages {
		names[stage.Slug] = stage.Name
	}
	return names
}
