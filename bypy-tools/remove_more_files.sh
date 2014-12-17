#!/bin/bash
MAX_FILE=${MAX_FILE:-10}
TAIL_VALUE=$((MAX_FILE+1))

if [[ ${REMOTE_DIR} == "" ]]; then
    echo "Please setup REMOTE_DIR env var."
    exit 1
fi

FILES=$(bypy.py list ${REMOTE_DIR} \$f time desc | grep ".zip")
if [[ ${FILES} == "" ]]; then
    echo "No zip files under ${REMOTE_DIR}."
    exit 0
fi

echo "### Files:"
echo "${FILES}"

LINE=$(echo "${FILES}" | wc -l)
echo "### Number: ${LINE}"

if [[ ${LINE} -gt ${MAX_FILE} ]]; then
    echo "### More than ${MAX_FILE} files."
    echo "### Start to remove:"
    REMOVED_LIST=$(echo "${FILES}" | tail -n +${TAIL_VALUE})
    echo "${REMOVED_LIST}"
    for REMOVE in ${REMOVED_LIST}; do
        bypy.py delete ${REMOTE_DIR}/${REMOVE}
    done
else
    echo "### Not more than ${MAX_FILE} files."
fi

