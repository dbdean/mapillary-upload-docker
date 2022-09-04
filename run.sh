#!/usr/bin/env bash
source .env

INPUT="${1:-/to_upload}"
IMPORT_PATH=$(mktemp -d)

# ensure docker image is built
docker build https://github.com/mapillary/mapillary_tools.git#main:docker \
       -t mapillary_tools:latest

# rename already uploaded files to done
grep "Sending upload_end via IPC" $INPUT/upload.log \
    | cut -f 8 -d ":" \
    | cut -f 1 -d "," \
    | cut -c 3- \
    | rev \
    | cut -c 2- \
    | rev \
    | xargs file \
    | grep ISO \
    | cut -d ':' -f1 \
    | xargs -ti mv {} {}-done


echo "Uploading videos from $INPUT (see $INPUT/upload.log)"
docker run \
       -v "$(pwd)/config.mapillary:/root/.config/mapillary" \
       -v "$(pwd)/to_upload:/to_upload" \
       -v "$IMPORT_PATH:$IMPORT_PATH" \
       -e "PYTHONUNBUFFERED=1" \
       --env-file .env \
       mapillary_tools:latest \
       mapillary_tools --verbose \
        upload_blackvue "$INPUT" \
        --user_name $MAPILLARY_USER \
  2>&1 | tee -a $INPUT/upload.log

