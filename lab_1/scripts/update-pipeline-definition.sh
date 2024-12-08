#!/bin/bash
BRANCH="main"
OWNER="unknown"
REPO="unknown"
POLL_FOR_SOURCE_CHANGES=false
BUILD_CONFIGURATION="production"
JSON_PATH="$1"
JQ_VERSION=$(command -v jq)

# Validate if the path to the pipeline definition JSON file is provided. If not, throw an error and stop execution
if [ -z "$1" ]; then
    echo "Error: No JSON file specified."
    exit 1
fi

# Validate if JQ is installed on the host OS. If not, display commands on how to install it on different platforms and stop script execution
if [ -z "$JQ_VERSION" ]; then
    echo "jq is not installed. Check https://jqlang.github.io/jq/download/ on how to download jq on different platforms"
    exit 1
fi

# Validate if the necessary properties are present in the given JSON definition. If not, throw an error and stop execution.
if ! jq -e '.pipeline | has("version")' "$JSON_PATH" > /dev/null; then
  echo "Error: Missing required 'version' properties in 'pipeline'"
  exit 1
fi

if ! jq -e '.metadata' "$JSON_PATH" > /dev/null; then
  echo "Error: Missing required metadata property"
  exit 1
fi

REQUIRED_NESTED_KEYS=("Branch" "Owner" "Repo" "PollForSourceChanges")

for key in "${REQUIRED_NESTED_KEYS[@]}"; do
    if ! jq -e ".pipeline.stages[0].actions[0].configuration | has(\"$key\")" "$JSON_PATH" >/dev/null; then
        echo "Error: Missing required key in pipeline.stages[0].actions[0].configuration: $key"
        exit 1
    fi
done

# Perform only 1.1 and 1.2 actions if no additional parameters are provided
if [ -z "$2" ]; then
    jq --arg branch "$BRANCH" --arg owner "$OWNER" --arg repo "$REPO" --arg poll_for_source_changes "$POLL_FOR_SOURCE_CHANGES" --arg configuration "$ENV_VAR_JSON_STRING" 'del(.metadata) |
 .pipeline.version += 1' "$JSON_PATH" >../pipeline-$(date +%Y%m%d).json
    exit 0
fi

# Check if branch, repo, pollForSourceChanges, build configuration and owner values are passed as arguments and update the corresponding variables
while [[ "$2" == --* ]]; do
    case "$2" in
    --branch)
        BRANCH="$3"
        shift 2
        ;;
    --owner)
        OWNER="$3"
        shift 2
        ;;
    --repo)
        REPO="$3"
        shift 2
        ;;
    --configuration)
        BUILD_CONFIGURATION="$3"
        shift 2
        ;;
    --poll_for_source_changes)
        POLL_FOR_SOURCE_CHANGES="$3"
        shift 2
        ;;
    *)
        shift
        ;;
    esac
done

ENV_VAR_JSON_STRING=$(jq -n \
    --arg config "$BUILD_CONFIGURATION" \
    '{ "name": "BUILD_CONFIGURATION", "value": $config, "type": "PLAINTEXT" } | @json')

# Copy the initial file to the output file and and apply all the required changes
jq --arg branch "$BRANCH" --arg owner "$OWNER" --arg repo "$REPO" --arg poll_for_source_changes "$POLL_FOR_SOURCE_CHANGES" --arg configuration "$ENV_VAR_JSON_STRING" 'del(.metadata) |
 .pipeline.version += 1 |
 .pipeline.stages[0].actions[0].configuration.Branch = $branch |
 .pipeline.stages[0].actions[0].configuration.Owner = $owner |
 .pipeline.stages[0].actions[0].configuration.Repo = $repo |
 .pipeline.stages[0].actions[0].configuration.PollForSourceChanges = $poll_for_source_changes |
 . |= (walk(if type == "object" and .EnvironmentVariables then .EnvironmentVariables = $configuration else . end))' "$JSON_PATH" >../pipeline-$(date +%Y%m%d).json
