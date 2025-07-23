#!/bin/bash

set -e

CURRENT_TAG="v1.0.0"
echo "Current tag: $CURRENT_TAG"

TAGS=($(git tag --list 'v*.*.*' | grep -E '^v[0-9]+\.[0-9]+\.[0-9]+$' | sort -V -r))
echo "Filtered tags: ${TAGS[@]}"

for i in "${!TAGS[@]}"; do
    if [[ "${TAGS[$i]}" == "$CURRENT_TAG" ]]; then
    if [[ $((i+1)) -lt ${#TAGS[@]} ]]; then
        PREVIOUS_TAG="${TAGS[$((i+1))]}"
        echo "Previous tag: $PREVIOUS_TAG"
    else
        echo "No previous tag found"
    fi
    break
    fi
done

if [[ -n $(git diff --name-only $PREVIOUS_TAG $CURRENT_TAG -- 'assistant/src/DbUpMigrator/*.sql') ]]; then
  migrations_changed=true
else
  migrations_changed=false
fi

if [[ -n $(git diff --name-only $PREVIOUS_TAG $CURRENT_TAG -- 'infrastructure/') ]]; then
  infrastructure_changed=true
else
  infrastructure_changed=false
fi

echo "migrations_changed=$migrations_changed" >> $GITHUB_OUTPUT
echo "infrastructure_changed=$infrastructure_changed" >> $GITHUB_OUTPUT