#!/bin/bash
param_number=0
for i in "$@"
do
param_number=$((param_number+1))
done
param_check='^[0-9]+$'
if [[ $param_number > 2 ]] 
then
echo "Error: Many parameters" >&2
exit 0
elif [[ ! $2 =~ $param_check ]]
then
echo "Error: Not a correct number of backups" >&2
exit 0
elif [[ $param_number < 2 ]]
then
echo "Error: Missing parameter" >&2
exit 0
elif [ ! -d "$1" ]
then
echo "Error: No such file or directory" >&2
exit 0
elif [ ! -d "/tmp/backups" ]
then
mkdir /tmp/backups
elif [ $2 -eq 0 ]
then
echo "Error: Not a correct number of backups" >&2
exit 0
fi


dir_pwd=$(dirname "$1")
dir_pwd=$(cd "$dir_pwd" && pwd)
x=`echo "$1" | awk -F / '{print $NF}'`
tar_name=$(echo "$dir_pwd-$x" | sed 's/^\///; s/\//-/')

archive_name_count="/tmp/backups/${tar_name}.${number}.tar.gz"
archive_name="/tmp/backups/${tar_name}.tar.gz"
if [ ! -f $archive_name ]
then
tar -zcf "$archive_name" -P "$1"
exit
fi
count_bkp=$(ls -la /tmp/backups/ | grep "$tar_name"  | wc -l)
if (( "$count_bkp" > "$2" ))
then
del_bkp=1
elif (( "$2" > "$count_bkp" ))
then
del_bkp=0
elif (( "$2" == "$count_bkp" ))
then
del_bkp=2
fi

if [ $2 -eq 1 ]
then
$(find /tmp/backups -type f -name "${tar_name}*" -delete)
tar -zcf "$archive_name" -P "$1"
exit
fi
if [ "$del_bkp" -eq 0 ]
then
for i in $(ls -la /tmp/backups/ | tail -n+4 | awk '{print $9}' | sort -r | tail -n+2)
do
index=$(echo "$i" | awk -F . '{print $(NF-2)}')
number=$(( $index+1 ))
$(mv /tmp/backups/"$i" /tmp/backups/${tar_name}.${number}.tar.gz)
done
number=1
$(mv $archive_name /tmp/backups/${tar_name}.1.tar.gz )
tar -zcf "$archive_name" -P "$1"
fi
if [ "$del_bkp" -eq 1 ]
then
for i in $(ls -la /tmp/backups/ | tail -n+$(( 2+$2 )) | awk '{print $9}' | sort | sed '$ d')
do
rm /tmp/backups/"$i"
done
for i in $(ls -la /tmp/backups/ | tail -n+4 | awk '{print $9}' | sort -r | tail -n+2)
do
index=$(echo "$i" | awk -F . '{print $(NF-2)}')
number=$(($index+1))
$(mv /tmp/backups/"$i" /tmp/backups/${tar_name}.${number}.tar.gz)
done
number=1
$(mv $archive_name /tmp/backups/${tar_name}.${number}.tar.gz )
tar -zcf "$archive_name" -P "$1"
fi
if [ "$del_bkp" -eq 2 ]
then
for i in $(ls -la /tmp/backups/ | tail -n+$(( 2+$2 )) | awk '{print $9}' | sort | sed '$ d')
do
rm /tmp/backups/"$i"
done
for i in $(ls -la /tmp/backups/ | tail -n+4 | awk '{print $9}' | sort -r | tail -n+2)
do
index=$(echo "$i" | awk -F . '{print $(NF-2)}')
number=$(($index+1))
$(mv /tmp/backups/"$i" /tmp/backups/${tar_name}.${number}.tar.gz)
done
number=1
$(mv $archive_name /tmp/backups/${tar_name}.${number}.tar.gz )
tar -zcf "$archive_name" -P "$1"
fi

