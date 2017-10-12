#!/bin/bash -e

# Description
#   This script generates ESGF mapfile.
#   Processes by dataset.
#
# Usage
#   ./mapfile.sh <PROJECT> <DATASET_PATH>
#
# Input
#   The project ID
#   <PROJECT>
#   A dataset full path as the directory that contains hardlinks
#   <DATASET_PATH>
#   /prodigfs/project/<PROJECT>/main/<downstream_DRS>/
#
# Output
#   ESGF mapfile
#   /prodigfs/esgf/mapfile/<PROJECT>/<downstream_DRS>/<DATASET_ID>.map

# --------- arguments & initialization --------- #

while [ "${1}" != "" ]; do
    case "${1}" in
        "--project")    shift; project="${1}"      ;;
        "--input-dir")  shift; input_dir="${1}"    ;;
        "--output-dir") shift; output_dir="${1}"   ;;
        "--script-dir") shift; scripts_path="${1}" ;;
        "--worker-log") shift; LOGFILE="${1}"      ;;
    esac
    shift
done

source ${scripts_path}/functions.sh

# --------- main --------- #

msg "INFO" "mapfile.sh started"
msg "INFO" "Input:  ${input_dir}"
msg "INFO" "Output: ${output_dir}"

if [ ${project} == "CMIP5" ] || [ ${project} == "CORDEX" ]; then
    project=$(echo ${project}-pp)
fi

esgprep mapfile -i ${scripts_path}/config/publication/. -v \
                --project ${project,,} \
                --outdir ${output_dir} \
                --no-version \
                --log ${LOGFILE} \
                --max-threads 16 \
                --no-cleanup \
                ${input_dir}

msg "INFO" "mapfile.sh complete"
