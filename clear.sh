#!/bin/bash
PATH=/usr/local/bin:/usr/bin:/usr/local/sbin:/usr/sbin
export PATH
LOG_DIR=/home/bdpai/domainDiff/logs
mkdir -p $LOG_DIR
time="$(date -d -1day +%Y%m%d)" # yesterday
mv $LOG_DIR/check_domain_resolve.log $LOG_DIR/check_domain_resolve_$time.log
find $LOG_DIR -mtime +1 -name "*.log" -exec rm -rf {} \




