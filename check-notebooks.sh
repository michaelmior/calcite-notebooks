#!/bin/bash

# Get the old version
version=$(jq -r '.metadata.language_info.version' query-optimization.ipynb)

for nb in $(ls *.ipynb); do
    # Execute the notebook and reset the version number
    jupyter nbconvert --to notebook --execute --inplace --clear-output "$nb"
    sed -i "s/\"version\": \"[^\"]*\"/\"version\": \"$version\"/" $nb
done

# Verify that the new output matches what was previously committed
git diff --exit-code
exit $?
