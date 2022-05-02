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

COMPARE_DIR=/home/bdpai/domaindiff

mkdir -p $COMPARE_DIR

# check ip change
function Check_Domain_Resolv(){
    while true
    do 
        > $COMPARE_DIR/current_domainlist.txt
        cat $file_name | while read line
        do
            # resolv ip address
            # timeout -s 9 2s 表示执行dig解析命令超时时间为2s，-s 9 功能和kill -9一样用于杀死进程，即如果超过2s没执行完会杀死dig执行进程，主要为了防止dig无法解析，出现卡住情况
            domain_ip_array=(`timeout -s 9 2s dig $line |grep -E "IN\s*A"|grep -oE "[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}"|sort -n|xargs -r`)
            # -e file 检测文件（包括目录）是否存在，如果是，则返回 true 
            # last_domainlist.txt 不存在，向其写入，否则向 current_domainlist.txt 中写入，last 上次结果，current 当前结果
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
                echo -e "["`date +"%Y-%m-%d %H:%M:%S"`"]    domain ip is changed, action: reload nginx" >> $COMPARE_DIR/check_domain_resolv.log
                echo "current_domain:" >> $COMPARE_DIR/check_domain_resolv.log
                cat $COMPARE_DIR/current_domainlist.txt >> $COMPARE_DIR/check_domain_resolv.log
                echo "before_domain:" >> $COMPARE_DIR/check_domain_resolv.log
                cat $COMPARE_DIR/last_domainlist.txt >> $COMPARE_DIR/check_domain_resolv.log
            else
                echo -e "["`date +"%Y-%m-%d %H:%M:%S"`"]    domain ip is not change, action: none" >> $COMPARE_DIR/check_domain_resolv.log
            fi
        fi
        cp -f $COMPARE_DIR/current_domainlist.txt $COMPARE_DIR/last_domainlist.txt
        > $COMPARE_DIR/current_domainlist.txt
        
        sleep 5
    done
}

Check_Domain_Resolv