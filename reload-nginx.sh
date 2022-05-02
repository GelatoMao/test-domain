#!/bin/bash

# get filename
if [ $# -eq 0 ]
then
    echo please use option -f filename
    exit 1
fi

# handle input parameters
while getopts "f:h" opt
do
    case $opt in
        f) 
            file_name=$OPTARG
            ;;
        h) 
            echo "please use option -f filename"
            exit 2
            ;;
        ?)
            echo "invalid option: -$opt"
            exit 1
            ;;
    esac
done

# check dig cmd
re=`which dig > /dev/null;echo $?`
if [ "$re" -ne 0 ]
then 
    echo "dig cmd does not exist"
    exit 3
fi

COMPARE_DIR=/home/bdpai/domainDiff
LOG_DIR=/home/bdpai/domainDiff/logs

mkdir -p $COMPARE_DIR
mkdir -p $LOG_DIR

# check ip change
function Check_Domain_Resolve(){
    while true
    do 
        > $COMPARE_DIR/current_domainlist.txt
        cat $file_name | while read line
        do
            # resolve ip address
            # if the dig execution process is not executed for more than 2s, it will kill the dig execution process, mainly to prevent dig from being parsed and stuck.
            domain_ip_array=(`timeout -s 9 2s dig $line |grep -E "IN\s*A"|grep -oE "[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}"|sort -n|xargs -r`)
            # last_domainlist.txt is the last result and current_domainlist.txt is the current result
            if [[ ! -e $COMPARE_DIR/last_domainlist.txt ]]
            then 
                for domain_ip in ${domain_ip_array[@]}
                do
                    echo -e "$line $domain_ip" >> $COMPARE_DIR/last_domainlist.txt
                done
            else
                for domain_ip in ${domain_ip_array[@]}
                do
                    echo -e "$line $domain_ip" >> $COMPARE_DIR/current_domainlist.txt
                done
            fi
        done

        # compare whether the current_domainlist.txt and last_domainlist.txt are equal
        if [[ -f $COMPARE_DIR/last_domainlist.txt && -f $COMPARE_DIR/current_domainlist.txt ]]
        then
            diff $COMPARE_DIR/current_domainlist.txt $COMPARE_DIR/last_domainlist.txt
            if [ $? -ne 0 ]
            then
                echo "different ip changed"
                /etc/init.d/nginx reload
                echo "nginx reloaded"
                echo -e "["`date +"%Y-%m-%d %H:%M:%S"`"]    domain ip is changed, action: reload nginx" >> $LOG_DIR/check_domain_resolve.log
                echo "current_domain:" >> $LOG_DIR/check_domain_resolve.log
                cat $COMPARE_DIR/current_domainlist.txt >> $LOG_DIR/check_domain_resolve.log
                echo "before_domain:" >> $LOG_DIR/check_domain_resolve.log
                cat $COMPARE_DIR/last_domainlist.txt >> $LOG_DIR/check_domain_resolve.log
            else
                echo -e "["`date +"%Y-%m-%d %H:%M:%S"`"]    domain ip is not change, action: none" >> $LOG_DIR/check_domain_resolve.log
            fi
        fi
        cp -f $COMPARE_DIR/current_domainlist.txt $COMPARE_DIR/last_domainlist.txt
        > $COMPARE_DIR/current_domainlist.txt
        
        sleep 5
    done
}

Check_Domain_Resolve