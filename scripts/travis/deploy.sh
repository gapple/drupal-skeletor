#!/usr/bin/env bash

set -e

# If this is pull request, exit.
if [[ ! $TRAVIS_PULL_REQUEST == 'false' ]]; then
  echo "::Testing pull request complete."
  exit;
fi

echo "::Deploying"

# Message needs to be determined while still in source repo directory.
PULL_REQUEST_MESSAGE=$(git log -n 1 --pretty=format:%s $TRAVIS_COMMIT)

# Note that you should have exported the Travis Repo SSH pub key, and
# added it into the deploy server keys list.

# Git config user/email
git config --global user.email "travis@myplanet.com"
git config --global user.name  "Travis CI - $ACQUIA_PROJECT"

git clone -b $DEPLOY_BRANCH --single-branch $DEPLOY_REPO $DEPLOY_DEST
rsync -a $PROJECT_ROOT/ $DEPLOY_DEST --exclude .git --delete

cd $DEPLOY_DEST
echo "::Adding new files."
git add --all .

echo "::Creating commit."
git commit -m "${PULL_REQUEST_MESSAGE}

Commit ${TRAVIS_COMMIT}"

echo "::Pushing to Acquia repository."
git push --progress origin $DEPLOY_BRANCH
