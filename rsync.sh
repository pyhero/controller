#!/bin/bash
#
# transfer files
# Author: Xu Panda
# Update: 2015-06-04

dir=$(cd `dirname $0`;echo $PWD)
# set iplist from $1
if [ -z $1 ];then
	echo "Useage: $0 {iplist file name}"
	echo "For example:"
	echo "		$0 ./iplist"
	echo ""
	exit 1
	elif [ ! -f $1 ];then
		echo "Invaild file."
		exit 2
fi
IL=$1

verify () {
	case $ver in
	        y)
	        break
	        ;;
	        n)
	        echo "Reinput ! "
		continue
	        ;;
	        *)
	        echo "Reinput ! "
		continue
	esac
}

# new file/dir path
while :
do
	read -p "The new file/dir path in this host: " np
	read -p "Verify:$np ,right? (y/n) " ver
	verify
done

# destination path
while :
do
	read -p "Destination path : " dp
	read -p "Verify:$dp ,right? (y/n) " ver
	verify
done

# scp and create script
fail_list=$dir/failed.list
if [ ! -f $fail_list ];then
        touch $fail_list
fi

while read ip port;do
	echo -e "\n\e[32mResult of $ip:\e[0m"
	if [ -z $port ];then
		port=22
	fi
	#/usr/bin/rsync --delete -avze ssh $np $ip:$dp
	/usr/bin/rsync -avze "ssh -p $port" $np $ip:$dp
	if [ $? -ne 0 ];then
                echo -e "$ip: \e[31mFailed\e[0m!"
		if ! grep -q $ip $fail_list;then
			echo $ip >> $fail_list
		fi
                echo ""
        fi
done < $IL

if [ -s $fail_list ];then
	echo -e "\n\e[31mSomeone failed:$fail_list\e[0m\n"
	echo -e "\e[32mYou must clear this file:\n\necho > $fail_list\e[0m\n\n"
fi
