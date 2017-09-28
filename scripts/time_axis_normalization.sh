#!/bin/bash -e

# Description
#   This script checks the time axis of files in directory.
#   Processes by variable.
#
# Usage
#   ./time_axis.sh <PROJECT> <VARIABLE_PATH>
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
        "--input-drs")  shift; input_drs="${1}"    ;;
        "--variable")   shift; variable="${1}"     ;;
        "--script-dir") shift; scripts_path="${1}" ;;
        "--worker-log") shift; LOGFILE="${1}"      ;;
    esac
    shift
done

source ${scripts_path}/functions.sh

# --------- main --------- #

# If no "input_dir" exit with status error = 0 to continue pipeline
if [ -z ${input_dir} ]; then
    msg "INFO" "time_axis_normalization.sh not executed (project=${project}, variable=${variable})"
    exit 0
fi

experiment=$(get_facet_from_path experiment ${input_dir} ${input_drs})
product=$(get_facet_from_path product ${input_dir} ${input_drs})

# If experiment is "historical" exit with status error = 0 to continue pipeline
if [ ${experiment} == "historical" ] && ([ ${product} == "bias-adjusted-output" ] || [ ${product} == "interpolated-output" ]); then
    msg "INFO" "time_axis_normalization.sh not executed (experiment=${experiment})"
    exit 0
fi

msg "INFO" "time_axis_normalization.sh started"
msg "INFO" "Input: ${input_dir}"

if [ ${product} == "bias-adjusted-output" ]; then
    project="${project}-Adjust"
fi

nctime axis -i ${scripts_path}/config/nctime.ini \
            --project ${project} \
            --write \
            --max-threads 8\
            --log ${LOGFILE} \
            ${input_dir}
            #--db \

if [ ${?} -eq 1 ]; then
    msg "ERROR" "time_axis_normalization.sh encounters an error"
    exit 1
else
    msg "INFO" "time_axis_normalization.sh complete"
fi
