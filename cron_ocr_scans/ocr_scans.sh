#!/bin/bash
SCRIPT=$(basename ${0})
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
SCAN_DIR="${1}"

ts () {
    echo -n "$(date +'%F-%R:%S ')${SCRIPT} - "
    echo $*
}

if [[ ! -d ${1} ]]; then
    ts "Provided scan dir"
    echo "${0} /usr/local/scans"
    exit 1
fi

ts "Start"

ts "Inspecting files in ${SCAN_DIR}"

SCAN_FILES=$(ls ${SCAN_DIR}/scan_[0-9]*pdf || (ts "${SCAN_DIR} not present"; exit 1))
NUM_SCAN_FILES=$(echo ${SCAN_FILES} | wc -w)

if [[ "${NUM_SCAN_FILES}" > "0" ]]; then
    ts "Found ${NUM_SCAN_FILES} to scan in ${SCAN_DIR}"
else
    ts "No files found in ${SCAN_DIR}, exiting"
    exit 0
fi

for PROCESS_DIR in originals processed
do
    if [[ ! -d "${SCAN_DIR}/${PROCESS_DIR}" ]]; then
        ts "${SCAN_DIR}/${PROCESS_DIR} directory not found, creating"
        mkdir ${SCAN_DIR}/${PROCESS_DIR}
    else
        ts "${SCAN_DIR}/${PROCESS_DIR} found"
    fi
done

for INPUT_FILE in ${SCAN_FILES}; do
    OUTPUT_FILE="${SCAN_DIR}/processed/ocr$(basename ${INPUT_FILE} | sed -e 's/.pdf$//g')_$(date +"%F-%H%M%S").pdf"
    ts "Processing ${INPUT_FILE} to ${OUTPUT_FILE}"
    /usr/bin/ocrmypdf -rdc ${INPUT_FILE} ${OUTPUT_FILE}
    ts "Moving ${INPUT_FILE} to ${SCAN_DIR}/originals"
    mv -v ${INPUT_FILE} ${SCAN_DIR}/originals
done

ts "Done"