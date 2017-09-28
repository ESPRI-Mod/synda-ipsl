#!/bin/bash -e

# Description
#   This script copies an atomic dataset between two directories creating hardlinks for every complete variable.
#   Processes by variable.
#
# Notes
#   - files removed in source are not removed from destination here (this has to be done by suppression pipeline)
#   - rsync '--delete' can't be used, as we merge TWO directory into one
#    (i.e. '--delete' only work with one directory mirroring one directory)
#
# Usage
#   ./copy.sh <PATH> <PROJECT>
#
# Input
#   The project ID
#   <PROJECT>
#   An atomic dataset full path as the directory that contains NetCDF files
#   <SRC_PATH>  : /prodigfs/esgf/process/<PROJECT>/<downstream_DRS>/
#
# Output
#   An atomic dataset full path as the directory that contains hardlinks
#   <DEST_PATH> : /prodigfs/project/<PROJECT>/main/<downstream_DRS>/

# --------- arguments & initialization --------- #

while [ "${1}" != "" ]; do
    case "${1}" in
        "--project")    shift; project="${1}"      ;;
        "--input-dir")  shift; src_path="${1}"     ;;
        "--input-drs")  shift; src_drs="${1}"      ;;
        "--output-dir") shift; dest_path="${1}"    ;;
        "--variable")   shift; variable="${1}"     ;;
        "--script-dir") shift; scripts_path="${1}" ;;
        "--worker-log") shift; LOGFILE="${1}"      ;;
    esac
    shift
done

source ${scripts_path}/functions.sh

# --------- main --------- #

# If no "input_dir" exit with status error = 0 to continue pipeline
if [ -z ${src_path} ]; then
    msg "INFO" "copy.sh not executed (project=${project}, variable=${variable})"
    exit 0
fi

experiment=$(get_facet_from_path experiment ${src_path} ${src_drs})
product=$(get_facet_from_path product ${src_path} ${src_drs})

# If experiment is "historical" exit with status error = 0 to continue pipeline
if [ ${experiment} == "historical" ] && ([ ${product} == "bias-adjusted-output" ] || [ ${product} == "interpolated-output" ]); then
    msg "INFO" "copy.sh not executed (experiment=${experiment})"
    exit 0
fi

msg "INFO" "copy.sh started"
msg "INFO" "Input:  ${src_path}"
msg "INFO" "Output: ${dest_path}"

if [ -d ${src_path} ]; then
    

    # mkdir is needed, because rsync expects destination path to exist (or at least parent folders in destination path).
    # More info: http://www.schwertly.com/2013/07/forcing-rsync-to-create-a-remote-path-using-rsync-path/
    umask g+w
    mkdir -p ${dest_path}
    umask g-w

    /usr/bin/rsync -viax --delete --link-dest=${src_path} ${src_path} ${dest_path}
    
fi

msg "INFO" "copy.sh complete"
