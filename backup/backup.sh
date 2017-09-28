#!/bin/bash -e

# Description
#   This script backup synda databases
#
# Notes
#   - Backup templates are useless because on GitHub versioning system
#   - Add the following line to the 'root' crontab of synda-prod
# 0 1 * * * /opt/synda-ipsl/maintenance/backup.sh >> /var/log/crontab.log 2>&1
#
# Usage
#   ./backup.sh
#

# ------ functions ------ #

curdate ()
{
    date +'%Y/%m/%d %I:%M:%S %p'
}

msg ()
{
    l__code="${1}"
    l__msg="${2}"

    echo "$(curdate) ${l__code} ${l__msg}" 1>&2
}


# --------- arguments & initialization --------- #

backup_dir="/prodigfs/backup/synda/$(date '+%Y%m%d')"
sqlite_backup_script="/opt/synda-ipsl/backup/backup.py"
db_path="/var/lib/synda"
log_path="/var/log/synda"
conf_path="/etc/synda"
log_archive_filename="logs.tar.gz"
conf_archive_filename="config.tar.gz"

# Create backup directory if not exist
mkdir -p ${backup_dir}


# --------- main --------- #

msg "INFO" "backup.sh script started"

msg "INFO" "Backup SDT database..."
${sqlite_backup_script} -d ${db_path}/sdt/sdt.db -b ${backup_dir}/sdt.db  # Backup SDT DB
msg "INFO" "Backup SDP database..."
${sqlite_backup_script} -d ${db_path}/sdp/sdp.db -b ${backup_dir}/sdp.db  # Backup SDP DB
msg "INFO" "Backup configuration files..."
tar -czf ${backup_dir}/${conf_archive_filename} ${conf_path}/{sdt,sdp}/sd*.conf 2> /dev/null  # Backup synda config files
msg "INFO" "Backup logs..."
tar -czf ${backup_dir}/${log_archive_filename} ${log_path}/{sdt,sdp,sdw}/*.log 2> /dev/null   # Backup synda log files

msg "INFO" "backup.sh script complete"
