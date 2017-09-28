#!/bin/bash -e

# Description
#   This script checks file overlaps in directory.
#   Processes by variable.
#
# Usage
#   ./overlap.sh <PROJECT> <VARIABLE_PATH>
#
# Input
#   The project ID
#   <PROJECT>
#   An atomic dataset full path as the directory that contains hardlinks
#   <VARIABLE_PATH>
#   /prodigfs/esgf/process/<PROJECT>/<downstream_DRS>/

# --------- arguments & initialization --------- #

while [ "${1}" != "" ]; do
    case "${1}" in
        "--project")    shift; project="${1}"      ;;
        "--input-dir")  shift; input_dir="${1}"    ;;
        "--script-dir") shift; scripts_path="${1}" ;;
        "--worker-log") shift; LOGFILE="${1}"      ;;
    esac
    shift
done

source ${scripts_path}/functions.sh

# --------- main --------- #

msg "INFO" "overlap.sh started"
msg "INFO" "Input: ${input_dir}"

nctime overlap -i ${scripts_path}/config/nctime.ini -v \
               --project ${project} \
               --resolve \
               --full-overlap-only \
               --log ${LOGFILE} \
               ${input_dir}

if [ ${?} -eq 1 ]; then
    msg "ERROR" "overlap.sh encounters an error"
    exit 1
else
    msg "INFO" "overlap.sh complete"
fi

