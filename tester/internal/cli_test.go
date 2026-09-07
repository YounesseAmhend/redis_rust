package internal

import (
	"encoding/json"
	"testing"

	"github.com/codecrafters-io/tester-utils/tester_context"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

func TestDefaultTestCasesUseFullStageNames(t *testing.T) {
	var cases []tester_context.TesterContextTestCase
	require.NoError(t, json.Unmarshal([]byte(defaultTestCasesJSON()), &cases))
	require.Len(t, cases, len(testerDefinition.TestCases))

	bySlug := map[string]tester_context.TesterContextTestCase{}
	for _, testCase := range cases {
		bySlug[testCase.Slug] = testCase
	}

	assert.Equal(t, "Bind to a port", bySlug["jm1"].Title)
	assert.Equal(t, "Respond to PING", bySlug["rg2"].Title)
	assert.Equal(t, "Implement the SET & GET commands", bySlug["la7"].Title)
	assert.Equal(t, "Create a list", bySlug["mh6"].Title)
	assert.Equal(t, "tester::#JM1", bySlug["jm1"].TesterLogPrefix)

	for _, testCase := range cases {
		assert.NotEqual(t, testCase.Slug, testCase.Title, "slug %s should not be used as the displayed title", testCase.Slug)
		assert.NotEmpty(t, testCase.Title)
	}
}

func TestNormalizedEnvFillsSlugTitles(t *testing.T) {
	env := normalizedEnv(map[string]string{
		"CODECRAFTERS_SUBMISSION_DIR":  "/tmp/redis",
		"CODECRAFTERS_TEST_CASES_JSON": `[{"slug":"jm1","tester_log_prefix":"stage-1","title":"jm1"}]`,
	})

	var cases []tester_context.TesterContextTestCase
	require.NoError(t, json.Unmarshal([]byte(env["CODECRAFTERS_TEST_CASES_JSON"]), &cases))
	require.Len(t, cases, 1)
	assert.Equal(t, "Bind to a port", cases[0].Title)
	assert.Equal(t, "stage-1", cases[0].TesterLogPrefix)
}

func TestNormalizedEnvKeepsExplicitTitles(t *testing.T) {
	env := normalizedEnv(map[string]string{
		"CODECRAFTERS_SUBMISSION_DIR":  "/tmp/redis",
		"CODECRAFTERS_TEST_CASES_JSON": `[{"slug":"jm1","tester_log_prefix":"tester::#JM1","title":"Stage #JM1 (jm1)"}]`,
	})

	var cases []tester_context.TesterContextTestCase
	require.NoError(t, json.Unmarshal([]byte(env["CODECRAFTERS_TEST_CASES_JSON"]), &cases))
	require.Len(t, cases, 1)
	assert.Equal(t, "Stage #JM1 (jm1)", cases[0].Title)
}
