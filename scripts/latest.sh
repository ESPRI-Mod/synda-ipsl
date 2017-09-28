#!/bin/bash -e

# Description
#   This script set "latest" symlinks.
#   Processes by dataset.
#
# Usage
#   ./latest.sh <PROJECT> <DATASET_PATH>
#
# Input
#   The project ID
#   <PROJECT>
#   A dataset full path as the directory that contains hardlinks
#   <DATASET_PATH>
#   /prodigfs/project/<PROJECT>/main/<downstream_DRS>/
#
# Output
#   The "latest" symlink
#   /prodigfs/project/<PROJECT>/main/<downstream_DRS>/latest -> vYYYYMMDD

# --------- arguments & initialization --------- #

while [ "${1}" != "" ]; do
    case "${1}" in
        "--project")    shift; project="${1}"      ;;
        "--input-dir")  shift; input_dir="${1}"    ;;
        "--input-drs")  shift; input_drs="${1}"    ;;
        "--root")       shift; root="${1}"         ;;
        "--script-dir") shift; scripts_path="${1}" ;;
        "--worker-log") shift; LOGFILE="${1}"      ;;
    esac
    shift
done

source ${scripts_path}/functions.sh

# --------- main --------- #

# If no "input_dir" exit with status error = 0 to continue pipeline
if [ -z ${input_dir} ]; then
    msg "INFO" "latest.sh not executed (project=${project})"
    exit 0
fi

dataset_dir=$( dirname ${input_dir} )
experiment=$(get_facet_from_path experiment ${input_dir} ${input_drs})
product=$(get_facet_from_path product ${input_dir} ${input_drs})

# If experiment is "historical" exit with status error = 0 to continue pipeline
if [ ${experiment} == "historical" ] && ([ ${product} == "bias-adjusted-output" ] || [ ${product} == "interpolated-output" ]); then
    msg "INFO" "latest.sh not executed (experiment=${experiment})"
    exit 0
fi

msg "INFO" "latest.sh started"
msg "INFO" "Input: ${input_dir}"

cd ${dataset_dir}

# Unlink existing "latest" symlink
if [ -h "latest" ]; then
    unlink "latest"
fi
# Remove existing "latest" folder
if [ -d "latest" ]; then
    rm -fr "latest"
fi

# Pick up latest version
latest_version=$(ls . | tail -1 2>&1)

if [ ${project} == "CMIP5" ] && [ ${product} == "output" ]; then

    # Rebuild output[12] directory
    output1_dir=$(echo "${root}/esgf/mirror/${project}${dataset_dir##*${project}}" | sed 's|output|output1|g')
    output2_dir=$(echo "${root}/esgf/mirror/${project}${dataset_dir##*${project}}" | sed 's|output|output2|g')

    if [ -d ${output1_dir} -a -d ${output2_dir} ]; then

         # Pick up output[12] latest version
        latest_output1=$(ls ${output1_dir} | tail -1 2>&1)
        latest_output2=$(ls ${output2_dir} | tail -1 2>&1)

        if [ "${latest_output1}" == "${latest_output2}" ]; then

            if [ "${latest_output1}" != "${latest_version}" ] || [ "${latest_output2}" != "${latest_version}" ]; then
                msg "ERROR" "Latest output[12] version differs from latest version"
                exit 1
            fi

            # Set new latest symlink
            ln -s ${latest_version} "latest"

        else

            if [ "${latest_output1}" != "${latest_version}" ] && [ "${latest_output2}" != "${latest_version}" ]; then
                msg "ERROR" "At least one of output[12] version has to be the latest version"
                exit 1
            fi

            for file in $(find ${dataset_dir}/{${latest_output1},${latest_output2}} -type f); do

                variable=$(echo ${file} | awk -F '/' '{print $14}')

                # Build latest/variable directory
                umask g+w
                mkdir -p "latest/${variable}"
                umask g-w

                cd "latest/${variable}"

                if [ -f $(basename ${file}) ]; then

                    # Unlink existing "file" symlink
                    rm -f $(basename ${file})

                    # Set new latest symlink with latest version from output1 or output2
                    ln "../../${latest_version}/$(echo ${file} | cut -d "/" -f 14-15)" $(basename ${file})

                else

                    # Set new latest symlink
                    ln "../../$(echo ${file} | cut -d "/" -f 13-15)" $(basename ${file})

                fi

                cd - >/dev/null 2>&1

            done

        fi

    else

        # Set new latest symlink
        ln -s ${latest_version} "latest"

    fi

else

    # Set new latest symlink
    ln -s ${latest_version} "latest"

fi

cd - >/dev/null 2>&1

msg "INFO" "latest.sh complete"
