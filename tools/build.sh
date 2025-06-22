#!/usr/bin/env bash

##
#  Prose - Docs
#  Build script
#
#  Copyright 2022, Prose Foundation
#  Author: Valerian Saliou https://valeriansaliou.name/
##

ABSPATH=$(cd "$(dirname "$0")"; pwd)
BASE_DIR="$ABSPATH/../"

: ${COMMAND:=build}

pushd "$BASE_DIR" > /dev/null
  cur_env="development"

  if [ ! -z "$1" ]; then
    cur_env="$1"
  fi

  config_path_all="./config/common.json,./config/$cur_env.json"
  config_path_local="./config/local.json"

  if [ -f "$config_path_local" ]; then
    config_path_all+=",$config_path_local"
  fi

  npm exec chappe "${COMMAND:?}" -- \
    --env="$cur_env" \
    --config="$config_path_all" \
    --assets="./res/assets" \
    --data="./src/data" \
    --dist="./build"
  rc=$?
popd > /dev/null

exit $rc
