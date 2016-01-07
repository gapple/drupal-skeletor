#!/bin/sh
# This is a quick rebuild script that doesn't do all the things that
# the full build script does.
#
# ## README ##
#
# This file is only meant to be used after switching branches.
#
# It backs up all the projects that were previously downloaded from the make
# file and then downloads again, in case something is new, removed or updated.
#
# The purpose of the backup is to make sure that we don't kill the user's dev
# environment in cases of a failed drush_make build or accidental running
# of the script.

DIRS="modules/contrib themes/contrib libraries/contrib"
for d in $DIRS; do
  if [ -e "$d.bak.tar.gz" ]
  then
    rm -f "$d.bak.tar.gz"
    echo "Old $d.bak.tar.gz deleted"
  fi
  if [ -e "$d" ]
  then
    mv "$d" "$d.bak"
    tar czf "$d.bak.tar.gz" "$d.bak"
    rm -Rf "$d.bak"
    echo "Archived $d to $d.bak.tar.gz"
  fi
done
drush make --yes --working-copy --no-core --no-cache --contrib-destination=. contrib.make.yml

# Copy default.settings.php and append snippets again.
chmod u+w ../../sites/default
rm -f ../../sites/default/settings.bak.php
mv ../../sites/default/settings.php ../../sites/default/settings.bak.php
cp ../../sites/default/default.settings.php ../../sites/default/settings.php
chmod 666 ../../sites/default/settings.php

echo "Appending settings.php snippets..."
for f in tmp/snippets/settings.php/*.settings.php
do
  # Concatenate newline and snippet, then append to settings.php
  echo "" | cat - $f | tee -a ../../sites/default/settings.php > /dev/null
done

# Seal settings.php
chmod 444 ../../sites/default/settings.php

# Finish by flushing caches.
drush cc all
