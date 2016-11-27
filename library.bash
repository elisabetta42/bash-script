#!/bin/bash

# Elisabetta Seggioli
# Jan-Philipp Heilmann

countConnectionAttempts () {
	sort -o tempFile1 $logfile
	temp=0
	firstLine=true
	while IFS='' read -r line
	do
	    set -- $line;
	    ipAddress=$1;
	    if [ "${ipField[$temp]}" == "$ipAddress" ]; then
	        ipCountField[$temp]=$((ipCountField[$temp]+1))
	    else
	    	if [ $firstLine==false ]; then
	    		temp=$((temp+1))
	    	fi
	    	firstLine=false
	        ipField[$temp]=$ipAddress
	        ipCountField[$temp]=1	        
	    fi
	done < tempFile1

	rm -f tempFile1

	for ((i=0;i<=${#ipField[@]};i++))
	do
	    echo ${ipField[$i]} ${ipCountField[$i]} >> tempFile2
	done

	sort -n -k 2 -r tempFile2 > tempFile1
	echo "IP addresses with the number of connection attempts:"
	if [ -z $n ]; then
		n=`wc -l < tempFile1`
	fi
	head -$n tempFile1

	rm -f tempFile1
	rm -f tempFile2
	
	unset ipField
	unset ipCountField
}

countSuccessfulConnectionAttempts () {

	awk '{print $1, $10 }' "$logfile" | sort > cfile
	temp=0
	ipcount=0

	while IFS= read -r line
	do
	    #awkVar= `echo $line | awk '{print $1}'`
	    set -- $line;
	    awkVar=$1;
	    awkVars=$2;
	    re='^[0-9]+$'
	    #echo "$awkVar" 
	    if [ "$awkVars" != "-" ] ; then
	        if [ "${ipField[$temp]}" == "$awkVar" ] ; then
	            ipCountField[$temp]=$((ipCountField[$temp]+1))
	        else
	            temp=$((temp+1))
	            ipField[$temp]=$awkVar
	            ipCountField[$temp]=1
	        fi
	    fi
	done < cfile

	for ((i=0;i<=${#ipField[@]};i++))
	do
	    echo ${ipField[$i]} ${ipCountField[$i]} >> mfile
	done;

	sort -n -k 2 -r mfile > sfile
	echo "number of successful connection attempts"
	if [ -z $n ]; then
		n=`wc -l < sfile`
	fi
	head -$n sfile

	rm -f sfile
	rm -f mfile
	rm -f cfile

	unset ipField
	unset ipCountField

}

mostCommonResultCodes () {

	awk '{print $1, $9 }' "$logfile" | sort -n -k 2,2 -k 1,1 > cfile
	temp=0
	while IFS= read -r line
	do
	    set -- $line;
	    awkVar=$1;
	    awkVars=$2;

	    
	    if [ "${resultCodeField[$temp]}" == "$awkVars" ] ; then
	    	resultCodeCountField[$temp]=$((resultCodeCountField[$temp]+1))
	    	if  [ "${ipField[$temp]}" != "$awkVar" ] || [ "${resultCodeField[$temp]}" != "$awkVars" ] ; then 
	        ipField[$temp]="$awkVar" 
	        echo "${ipField[$temp]}" "${resultCodeField[$temp]}" >> mfile   
	        fi   

	    else
	    	temp=$((temp+1))
	    	resultCodeField[$temp]=$awkVars
	    	resultCodeCountField[$temp]=1
	    	ipField[$temp]="$awkVar"
	    	 echo "${ipField[$temp]}" "${resultCodeField[$temp]}"  >> mfile   
	    fi
	done < cfile

	temp=-1

	while IFS= read -r line
	do
		set -- $line;
		awkVar=$1;
	    awkVars=$2;
    for ((i=0;i<=${#resultCodeField[@]};i++))
	do
    if [ "${resultCodeField[$i]}" == "$awkVars" ];then
    	echo "${awkVar}" "${resultCodeField[$i]}" "${resultCodeCountField[$i]}"   >> sfile    
    else
    	temp=$((temp+1))
    fi	
    done
	done < mfile
    
    echo "ip order by most commond result codes:"
    sort -n -k 3 -r sfile

	rm -f cfile
	rm -f mfile
	rm -f sfile

}

getMaxBytes () {
	awk '{print $1, $10 }' "$logfile" | sort > cfile
	temp=0
	ipcount=0

	while IFS= read -r line
	do
	    #awkVar= `echo $line | awk '{print $1}'`
	    set -- $line;
	    awkVar=$1;
	    awkVars=$2;
	    re='^[0-9]+$'
	    #echo "$awkVar" 
	    if [ "$awkVars" != "-" ] ; then
	        if [ "${ipField[$temp]}" == "$awkVar" ] ; then
	            ipCountField[$temp]=$((ipCountField[$temp]+$awkVars))
	        else
	            temp=$((temp+1))
	            ipField[$temp]=$awkVar
	            ipCountField[$temp]=$awkVars
	        fi
	    fi
	done < cfile

	for ((i=0;i<=${#ipField[@]};i++))
	do
	    echo ${ipField[$i]} ${ipCountField[$i]} >> mfile
	done;

	sort -n -k 2 -r mfile > sfile
	echo "most bytes sent to them"
	if [ -z $n ]; then
		n=`wc -l < sfile`
	fi
	head -$n sfile

	rm -f sfile
	rm -f mfile
	rm -f cfile

	unset ipField
	unset ipCountField
}