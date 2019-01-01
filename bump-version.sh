#!/bin/bash

# This script is designed to bump the version in all notebooks and
# then rerun them to ensure the output hasn't changed.
# Note that it's very primitive and will simply search for the current
# version string so it may change things it's not supposed to.

VERSION=1.17.0
BUMP_TYPE=minor

if [ $# -eq 1 ]; then
  BUMP_TYPE=$1
fi
if [ $# -gt 1 ]; then
  >&2 echo "usage: $0 [<bump_type>]"
  exit 1
fi

if ! git diff --exit-code &> /dev/null; then
  >&2 echo "Commit all changes before proceeding."
  exit 1
fi

escaped_version=$(echo $VERSION | sed 's/\./\\\./g')
new_version=$(./semver bump $BUMP_TYPE $VERSION 2> /dev/null)

if [ $? -ne 0 ]; then
  >&2 echo "Error bumping version. Bump type should be one of major, minor, or patch."
  exit 1
fi

echo "Changing from version $VERSION to $new_version..."
sed -i "s/$escaped_version/$new_version/g" *.ipynb bump-version.sh

echo "Rerunning notebooks..."
if ! jupyter nbconvert --to notebook --execute --inplace --clear-output *.ipynb 2> /dev/null; then
  >&2 echo "Error rerunning notebooks."
  exit 1
fi

git diff --exit-code *.ipynb;

echo "Version changed successfully. Review output above before committing."
