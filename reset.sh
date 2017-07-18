#!/bin/bash -e
synda_wo stop
service sdt stop
service sdp stop
sleep 8
rm -f /var/lib/synda/sdt/sdt.db
rm -f /var/lib/synda/sdp/sdp.db
rm -f /var/log/synda/sdp/*
rm -f /var/log/synda/sdt/*
rm -f /tmp/sdt_stacktrace*
rm -f /tmp/sdp_stacktrace*
rm -fr /prodigfs/prodigfs_dev/esgf/mapfiles/*/*
rm -fr /prodigfs/prodigfs_dev/esgf/mirror/*/*
rm -fr /prodigfs/prodigfs_dev/esgf/process/*/*
rm -fr /prodigfs/prodigfs_dev/project/*/*
service sdt start
service sdp start
chmod g+w /var/lib/synda/sdt/sdt.db
chmod g+w /var/lib/synda/sdp/sdp.db
date > /tmp/reset.log
