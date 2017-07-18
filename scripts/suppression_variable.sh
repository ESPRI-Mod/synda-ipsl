#!/bin/bash -e

# Description
#   This script removes the atomic dataset from "<ROOT>/esgf/process" output directory.
#   Processes by variable.
#
# Usage
#   ./suppression_variable.sh <PROJECT> <INPUT_DIR>
#
# Input
#   The project ID
#   <PROJECT>
#   An atomic dataset full path as the directory that contains NetCDF files
#   <VARIABLE_PATH>

# --------- arguments & initialization --------- #

while [ "${1}" != "" ]; do
    case "${1}" in
        "--project")    shift; project="${1}"      ;;
        "--input-dir")  shift; input_dir="${1}"    ;;
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
    msg "INFO" "suppresion_variable.sh not executed (project=${project}, variable=${variable})"
    exit 0
fi

msg "INFO" "suppression_variable.sh started"
msg "INFO" "Input: ${input_dir}"

if [ -d ${input_dir} ]; then
    # Remove files
    find ${input_dir} -mindepth 1 -maxdepth 1 -type f -delete 2>&1

    # Remove parent directory and upstream DRS if empty
    rmdir -p ${input_dir} --ignore-fail-on-non-empty
fi

msg "INFO" "suppression_variable.sh complete"
