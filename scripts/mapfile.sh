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

if [ ${project} == "c3scmip5" ] || [ ${project} == "c3scordex" ]; then

    esgprep mapfile -i ${scripts_path}/config/publication/. -v \
                    --project ${project,,} \
                    --outdir ${output_dir} \
                    --max-threads 16 \
                    --no-cleanup \
                    ${input_dir}

else

    esgprep mapfile -i ${scripts_path}/config/publication/. -v \
                    --project ${project,,} \
                    --outdir ${output_dir} \
                    --no-version \
                    --max-threads 16 \
                    --no-cleanup \
                    ${input_dir}

fi

msg "INFO" "mapfile.sh complete"
