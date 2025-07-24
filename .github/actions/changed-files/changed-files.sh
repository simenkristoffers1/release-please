#!/bin/bash

set -e

IFS=',' read -r -a pattern_array <<< "${{ inputs.patterns }}"

# Final array to hold the full pathspecs.
pathspec_array=()
for pattern in "${pattern_array[@]}"; do
    # Trim leading/trailing whitespace from each pattern (e.g., " *.js " -> "*.js").
    trimmed_pattern=$(echo "$pattern" | xargs)
    # Add the directory and cleaned pattern to the array, ignoring empty entries.
    if [[ -n "$trimmed_pattern" ]]; then
        pathspec_array+=("${{ inputs.directory }}/$trimmed_pattern")
    fi
done

# Combine directory and pattern into a pathspec for git
echo "ℹ️ Checking for changed files with pathspecs: ${pathspec_array[@]}"

# Pass the array of pathspecs to git diff. The quotes are essential.
CHANGED_FILES=$(git diff --name-only ${{ inputs.base-sha }}..HEAD -- "${pathspec_array[@]}")

if [[ -n "$CHANGED_FILES" ]]; then
    # Trim the directory prefix from the beginning of each file path.
    TRIMMED_PATHS=$(echo "$CHANGED_FILES" | sed "s|^${{ inputs.directory }}/||")

    echo "✅ Found changed files (paths relative to directory):"
    echo "$TRIMMED_PATHS"

    echo 'files<<EOF' >> "$GITHUB_OUTPUT"
    echo "$TRIMMED_PATHS" >> "$GITHUB_OUTPUT"
    echo 'EOF' >> "$GITHUB_OUTPUT"
else
    echo "ℹ️ No changed files found for the given pathspec."
    echo "files=" >> "$GITHUB_OUTPUT"
fi