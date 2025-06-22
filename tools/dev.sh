#!/usr/bin/env bash

##
#  Prose - Docs
#  Build script
#
#  Copyright 2025, Prose Foundation
#  Author: Valerian Saliou https://valeriansaliou.name/
##

ABSPATH=$(cd "$(dirname "$0")"; pwd)
BASE_DIR="$ABSPATH/../"

pushd "$BASE_DIR" > /dev/null
  COMMAND=serve ./tools/build.sh "$1"
  rc=$?
popd > /dev/null

exit $rc
