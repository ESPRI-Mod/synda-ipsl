#!/bin/bash -e

# Description
#   This script migrates data from source to destination directory.
#   Processes by dataset.

# --------- arguments & initialization --------- #

while [ "${1}" != "" ]; do
    case "${1}" in
        "--project")         shift; project="${1}"       ;;
        "--input-dir")       shift; src_path="${1}"     ;;
        "--output-dir")      shift; dest_path="${1}"    ;;
        #"--dataset_pattern") shift; input_dataset="${1}" ;;
        "--script-dir")      shift; scripts_path="${1}" ;;
    esac
    shift
done

source ${scripts_path}/functions.sh

# --------- main --------- #

msg "INFO" "migration.sh started"

/usr/bin/rsync -viax --link-dest=${src_path} ${src_path} ${dest_path}

msg "INFO" "migration.sh complete"
