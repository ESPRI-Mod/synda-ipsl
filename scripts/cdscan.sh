#!/bin/bash -e

# Description
#   This script apply cdscan cdat-command on a variable,
#   creating xml aggregation for every variable existing in directory.
#   Processes by variable.
#
# Notes
#   - python dependencies : cdat or cdat_lite
#
# Usage
#   ./cdscan.sh <PROJECT> <SCR_PATH> <DEST_PATH>
#
# Input
#   The project ID
#   <PROJECT>
#   An atomic dataset full path as the directory that contains NetCDF files
#   <SRC_PATH>  : /prodigfs/esgf/process/<PROJECT>/<downstream_DRS>/
#
# Output
#   An atomic dataset full path as the directory that contains XML aggregation files
#   <DEST_PATH> : /prodigfs/project/<PROJECT>/main/<downstream_DRS>/

# --------- arguments & initialization --------- #

while [ "${1}" != "" ]; do
    case "${1}" in
        "--input-dir")  shift; input_dir="${1}"    ;;
        "--input-drs")  shift; input_drs="${1}"    ;;
        "--output-dir") shift; output_dir="${1}"   ;;
        "--script-dir") shift; scripts_path="${1}" ;;
        "--worker-log") shift; LOGFILE="${1}"      ;;
    esac
    shift
done

source ${scripts_path}/functions.sh

export LD_LIBRARY_PATH=/usr/local/lib:${LD_LIBRARY_PATH}

# --------- main --------- #

frequency=$(get_facet_from_path time_frequency ${input_dir} ${input_drs})
if [ ${frequency} == "fx" ]; then
    msg "INFO" "cdscan.sh not executed (frequency=${frequency})"
    exit 0
fi

msg "INFO" "cdscan.sh started"
msg "INFO" "Input:  ${input_dir}"
msg "INFO" "Output: ${output_dir}"

umask g+w
mkdir -p ${output_dir}
umask g-w

xml_output=$( ls ${input_dir} | head -1 | sed 's|\_[0-9]*\-[0-9]*\.nc$|\.xml|g' )

# Safeguard
if [ ${xml_output} == $(ls ${input_dir} | head -1) ]; then
    msg "ERROR" "XML output has same filename as NetCDF file."
    exit 1
fi

cdscan -x ${output_dir}${xml_output} ${input_dir}*.nc 1>&2

msg "INFO" "cdscan.sh complete"
