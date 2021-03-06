#!/usr/bin/env bash

# Start serving the site
php \
  --server 127.0.0.1:8080 \
  --docroot $TRAVIS_BUILD_DIR/build &

# Exit script early if unless in secure environment with credentials available.
[[ "$TRAVIS_SECURE_ENV_VARS" == "false" ]] && exit

# Running selenium tests.
cd $TRAVIS_BUILD_DIR/tmp/tests
TEST_CMD='se-interpreter selenium/interpreter_config.json'

if $TEST_CMD; then
  PASS_STATE=true
else
  PASS_STATE=false
fi

# Get Saucelabs sessionID, and set pass state.
JSON_RESPONSE=$(http --body --auth $SAUCE_USERNAME:$SAUCE_ACCESS_KEY GET https://saucelabs.com/rest/v1/$SAUCE_USERNAME/jobs full==true)
SESSION_ID=$(ruby -r 'json' -e "\$stdout.write JSON.parse('$JSON_RESPONSE').keep_if {|job| job['browser'] == '$SAUCE_BROWSER' && job['build'] == '$TRAVIS_BUILD_NUMBER' }[0]['id']")
http --auth $SAUCE_USERNAME:$SAUCE_ACCESS_KEY PUT https://saucelabs.com/rest/v1/$SAUCE_USERNAME/jobs/$SESSION_ID passed:=$PASS_STATE

# Mark Travis build as failed.
if [[ "$PASS_STATE" == "false" ]]; then
  exit 1
fi
