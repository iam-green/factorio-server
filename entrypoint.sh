#!/bin/bash
set -e

CMD="./start.sh \
  -v ${VERSION} \
  -m ${MAP_NAME} \
  -p ${PORT} \
  -d ${DATA_DIRECTORY} \
  -ld ${LIBRARY_DIRECTORY} \
  -fd ${FACTORIO_DIRECTORY}"

[ "${WHITELIST_ENABLE}" = "true" ] && CMD="$CMD -w"
[ "${ELEVATED_RAILS_ENABLE}" = "true" ] && CMD="$CMD -er"
[ "${QUALITY_ENABLE}" = "true" ] && CMD="$CMD -q"
[ "${SPACE_AGE_ENABLE}" = "true" ] && CMD="$CMD -sa"

# Execute the final command
exec $CMD
