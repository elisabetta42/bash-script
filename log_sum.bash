#!/bin/bash
. library.bash

# Elisabetta Seggioli
# Jan-Philipp Heilmann

echo "Script log_sum.bash started!"

# bash only no error handling
logfile=$BASH_ARGV
if [ ! -f $logfile ]; then
    echo "File not found!"
    exit -1
fi

if [ "$1" == "-n" ]; then
	n=$2
	OPTIND=3
fi

control=false
while getopts :c2rFt option
do
	case $option in
	c)
		countConnectionAttempts
		control=true
		;;
	2)
		countSuccessfulConnectionAttempts
		control=true
		;;
	r)
		mostCommonResultCodes
		control=true
		;;
	F)
		control=true
		;;
	t)
		getMaxBytes
		control=true
		;;
	*)
		echo "Unknown argument!"
		;;
	esac
done

if [ $control == false ]; then
	echo "A parameter is missing!"
fi