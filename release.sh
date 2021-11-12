#!/bin/bash

# This script updates the version, creates a tag and pushes it in order to prepare a new release

# Usage:
# ./release.sh # you will be asked for the version
# ./release.sh 1.2.3

branch=$(git symbolic-ref HEAD | sed -e 's,.*/\(.*\),\1,')
projectName=$(git config --local remote.origin.url|sed -n 's#.*/\([^.]*\)\.git#\1#p')

# check current Git branch
if [ $branch != "main" ]; then
  echo "You can only release from the main branch"
  exit 1
fi

if [ $# -eq 0 ]; then
  echo "Enter the release version number (e.g. 1.2.3):"
  read versionNumber
  versionLabel=v$versionNumber
else
  versionLabel=v$1
fi

echo "Updating version to $versionLabel for $projectName"

# pull the latest version of the code from master
git pull

# update version file
echo "$versionLabel" > version.txt

# commit this change
git commit version.txt -m "Update to version $versionLabel"
git push

# create tag for new version
git tag -a $versionLabel -m "Releasing version $versionLabel"
git push origin --tags

echo "Version is set to $versionLabel"
