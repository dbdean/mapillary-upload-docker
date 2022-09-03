#!/usr/bin/env bash
source .env

INPUT="${1:-/to_upload}"
IMPORT_PATH=$(mktemp -d)

echo "Uploading videos from $INPUT"

docker build https://github.com/mapillary/mapillary_tools.git#main:docker \
       -t mapillary_tools:latest

docker run \
       -v "$(pwd)/config.mapillary:/root/.config/mapillary" \
       -v "$(pwd)/to_upload:/to_upload" \
       -v "$IMPORT_PATH:$IMPORT_PATH" \
       -e "PYTHONUNBUFFERED=1" \
       --env-file .env \
       mapillary_tools:latest \
       mapillary_tools --verbose \
        video_process_and_upload "$INPUT" "$IMPORT_PATH" \
        --user_name $MAPILLARY_USER \
        --geotag_source "blackvue_videos" \
        --geotag_source_path "$INPUT" \
        --interpolate_directions \
        --video_sample_interval 0.5 \
        --device_make "Blackvue" \
        --device_model "DR900S-1CH" \
        --overwrite_EXIF_gps_tag \
        --duplicate_distance 1.0 \
        --skip_process_errors

