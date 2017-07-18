#!/bin/bash -e

# Description
#   Creates file hardlinks between input and output directories.
#   Processes by variable.
#
# Notes
#   - rsync '--delete' can't be used, as we merge TWO directory into one
#    (i.e. '--delete' only work with one directory mirroring one directory)
#
# Usage
#   ./coalesce.sh <PROJECT> <SCR_PATH> <DEST_PATH>
#
# Input
#   The project ID
#   <PROJECT>
#   An atomic dataset full path as the directory that contains NetCDF files
#   <SRC_PATH>  : /prodigfs/esgf/mirror/<PROJECT>/<downstream_DRS>/
#
# Output
#   An atomic dataset full path as the directory that contains hardlinks
#   <DEST_PATH> : /prodigfs/esgf/process/<PROJECT>/<downstream_DRS>/

# --------- arguments & initialization --------- #

while [ "${1}" != "" ]; do
    case "${1}" in
        "--project")    shift; project="${1}"      ;;
        "--input-dir")  shift; src_path="${1}"     ;;
        "--output-dir") shift; dest_path="${1}"    ;;
        "--script-dir") shift; scripts_path="${1}" ;;
        "--worker-log") shift; LOGFILE="${1}"      ;;
    esac
    shift
done

source ${scripts_path}/functions.sh

if [ ${project} == "CMIP5" ]; then
    output1_path=$( echo "${src_path}" | sed 's|/\*/|/output1/|' )
    output2_path=$( echo "${src_path}" | sed 's|/\*/|/output2/|' )
fi

# --------- main --------- #

msg "INFO" "coalesce.sh started"
msg "INFO" "Input:  ${src_path}"
msg "INFO" "Output: ${dest_path}"

# This is needed, because rsync expects destination path to exist (or at least parent folders in destination path).
# More info: http://www.schwertly.com/2013/07/forcing-rsync-to-create-a-remote-path-using-rsync-path/
umask g+w
mkdir -p ${dest_path}
umask g-w

if [ ${project} == "CMIP5" ]; then

    if [ -d ${output1_path} -a -d ${output2_path} ]; then

        nbr=$( comm -12  <(ls ${output1_path} | sort ) <(ls ${output2_path} | sort ) | wc -l ) # List files that intersect both outputs

        if [ ${nbr} -gt 0 ]; then
            # Duplicate(s) found
            msg "INFO" "${nbr} duplicate(s) found b/w output1 and output2 (${src_path})"
            # Notification to administrator -> To forward to modeling center/data provider/manager?
            send_mail "glipsl@ipsl.jussieu.fr" "${nbr} duplicate(s) found b/w output1 and output2.\n$( comm -12  <(ls ${output1_path} | sort ) <(ls ${output2_path} | sort ))" "SYNDA: Duplicated CMIP5 files in output1 and output2"

            # Merge using ln as this case is difficult to solve with rsync (rsync copy file instead of linking when file exists in destination (maybe lustre specific)). It was decided to merge duplicated from output1.
            cd ${dest_path}
            for f in $( ls ${output1_path} ); do
                ln ${output1_path}${f} ${f}
            done
            for f in $( comm -13  <(ls ${output1_path} | sort ) <(ls ${output2_path} | sort ) ); do # List files that exist in output2 only
                ln ${output2_path}${f} ${f}
            done
        else
            if [ -d ${output1_path} ]; then
                /usr/bin/rsync -viax --link-dest=${output1_path} ${output1_path} ${dest_path}
            fi

            if [ -d ${output2_path} ]; then
                /usr/bin/rsync -viax --link-dest=${output2_path} ${output2_path} ${dest_path}
            fi
        fi
    else
        if [ -d ${output1_path} ]; then
            /usr/bin/rsync -viax --link-dest=${output1_path} ${output1_path} ${dest_path}
        fi

        if [ -d ${output2_path} ]; then
            /usr/bin/rsync -viax --link-dest=${output2_path} ${output2_path} ${dest_path}
        fi
    fi

else

    if [ -d ${src_path} ]; then
        /usr/bin/rsync -viax --link-dest=${src_path} ${src_path} ${dest_path}
    fi

fi

# Move .nc4 files to .nc files
for nc4_file in $(find ${dest_path} -type f -name "*.nc4"); do
    nc_file=$(echo "${nc4_file}" | sed 's|\.nc4$|\.nc|g')
    mv -f ${nc4_file} ${nc_file}
done

msg "INFO" "coalesce.sh complete"
