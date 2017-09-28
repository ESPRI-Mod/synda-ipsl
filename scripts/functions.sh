#!/bin/bash -e

# Description
#   This script gathers useful functions used by post-processing scripts.

curdate ()
{
    date +'%Y/%m/%d %I:%M:%S %p'
}

msg ()
{
    LEVEL="${1}"
    MSG="${2}"
    if [ ! -z ${LOGFILE} ] && [ -f ${LOGFILE} ]; then
        echo "$(curdate) ${LEVEL} ${MSG}" 1>> ${LOGFILE}
    else
        echo "$(curdate) ${LEVEL} ${MSG}" 1>&2
    fi
}

send_mail ()
{
    DEST="${1}"
    TEXT="${2}"
    OBJ="${3}"
    # Send email to data provider in argument
    if [ -n "${DEST}" ]; then
        echo "${TEXT}" | mail -s "${OBJ}" "${DEST}"
    fi
}

get_facet_from_path ()
{
    key="${1}"  # The facet key to get the value
    path="${2}" # The input path to match
    drs="${3}"  # The corresponding DRS template

	l__path=$(echo ${path} | awk -F "/" '{print NF}')
	l__drs=$(echo ${drs} | awk -F "/" '{print NF}')

	offset=$(echo "${l__path} - ${l__drs}" | bc)
	key_rank=$(echo ${drs} |  awk -F "/" '{for (i=1;i<=NF;i++){if ($i == "'${key}'"){print i}}}')
    if [ -z ${key_rank} ]; then
	    exit 1
    else
	    value_rank=$(echo "${key_rank} + ${offset}" | bc)
        value=$(echo ${path} | awk -F "/" '{print $'${value_rank}'}')
        echo ${value}
    fi
}

return_code ()
{
    code="${1}"  # Return code value
    commande="${2}" # commande 
    if [[ ${code} != 0 ]]; then
        msg "ERROR" "${commande} FAILED"
        exit 1
    fi
}

test_meta_data()
{
    meta=${1}
    length_meta=${#meta}
    if [[ ${length_meta} == 0 ]]; then
        meta="unknown"
    fi
    echo ${meta}
}

convert_to_integer()
{
    result=${1}
    test_string=$(echo ${result} | grep "\"" | wc -l )
    if [[ ${test_string} -gt 0 ]]; then
        result=$(echo ${result} | awk -F "\"" '{print $2}')
    fi
    test_float=$(echo ${result} | grep "." | wc -l )
    if [[ ${test_float} -gt 0 ]]; then
        result=$(echo ${result} | awk -F "." '{print $1}')
    fi
    echo ${result}
}



extract_time_series()
{
    start_year="${1}"    # Start year of the time series
    end_year="${2}"      # End year of the time series
    PATH_DIR="${3}"      # Directory of the NetCDF file
    DATA_TMP_DIR="${4}"  # Directory of extract file
    JOB_ID="${5}"        # Job ID
    i="${6}"             # Counter
    k="${7}"             # Period number
    rcp="${8}"

    cd ${PATH_DIR} ; list=$( ls *.nc)
    for file in ${list} ; do
        file_without_ext=$(echo ${file} | awk -F ".nc" '{print $1}' )
        dates=$(echo ${file_without_ext} | awk -F "_" '{print $NF}' )
        start_date=$(echo ${dates} | awk -F "-" '{print $1}' )
        end_date=$(echo ${dates} | awk -F "-" '{print $2}' )
        start_year_file=$(echo ${start_date:0:4})
        end_year_file=$(echo ${end_date:0:4})

        if [[ ${start_year_file} -le ${start_year} && ${end_year_file} -ge ${start_year} ]]; then
            i=$(echo "(${i}+1)" | bc)
            if [[ ${i} -lt 10 ]]; then
		i=$( echo "0${i}")
            fi
            if [[ ${rcp} == "historical" && ${end_year_file} -gt 2005 ]];then
                cdo -O selyear,${start_year_file}/2005 ${PATH_DIR}/${file} \
                ${DATA_TMP_DIR}/${JOB_ID}_tmp_${i}_${k}.nc
            else
            	cp ${PATH_DIR}/${file} ${DATA_TMP_DIR}/${JOB_ID}_tmp_${i}_${k}.nc
	    fi
        fi
        if [[ ${start_year_file} -gt ${start_year} && ${end_year_file} -le ${end_year} ]]; then
            i=$(echo "(${i}+1)" | bc)
            if [[ ${i} -lt 10 ]]; then
		i=$( echo "0${i}")
            fi
	    if [[ ${rcp} == "historical" && ${end_year_file} -gt 2005 ]];then
                cdo -O selyear,${start_year_file}/2005 ${PATH_DIR}/${file} \
                ${DATA_TMP_DIR}/${JOB_ID}_tmp_${i}_${k}.nc
            else
            	cp ${PATH_DIR}/${file} ${DATA_TMP_DIR}/${JOB_ID}_tmp_${i}_${k}.nc
	    fi	
        fi
        if [[ ${start_year_file} -gt ${start_year} && ${start_year_file} -le ${end_year}  && ${end_year_file} -gt ${end_year} ]]; then
            i=$(echo "(${i}+1)" | bc)
            if [[ ${i} -lt 10 ]]; then
		i=$( echo "0${i}")
            fi
 	    if [[ ${rcp} == "historical" && ${end_year_file} -gt 2005 ]];then
                cdo -O selyear,${start_year_file}/2005 ${PATH_DIR}/${file} \
                ${DATA_TMP_DIR}/${JOB_ID}_tmp_${i}_${k}.nc
            else
            	cp ${PATH_DIR}/${file} ${DATA_TMP_DIR}/${JOB_ID}_tmp_${i}_${k}.nc
	    fi
        fi
    done
    echo ${i}
}
