#!/bin/bash
#
# run your command to ervery ser.
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

# get command from read
while :
do
	read -p "Your command : " com
	read -p "Verify: $com ,right? (y/n) " ver
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
done

# doit
fail_list=$dir/failed.list
if [ ! -f $fail_list ];then
	touch $fail_list
fi

cat $IL | while read ip port;do
	echo -e "\n\e[32mResult of $ip:\e[0m"
	if [ -z $port ];then
		port=22
	fi
	0</dev/null ssh -p $port $ip $com
	if [ $? -ne 0 ];then
		echo -e "$ip: \e[31mFailed\e[0m!"
		if ! grep -q $ip $fail_list;then
			echo $ip >> $fail_list
		fi
		echo ""
	fi
done

if [ -s $fail_list ];then
	echo -e "\n\n\e[31mSomeone failed:$fail_list\e[0m\n\n"
	echo -e "\e[32mYou must clear this file:\n\necho > $fail_list\e[0m\n\n"
fi
