#!/bin/bash

listfile="filelist.txt"
indexfile="temp_index.html"
endfile="temp_index_end.html"
ihtml="index.html"
myname="update.sh"
blklist="blacklist.txt"
# get file list and write file info to config
echo "=====reading files====="
for filename in $(ls)
do
    fileflag="Y"
    echo -e "$filename :\t\c"
    while read LINE
    do
        [[ ${LINE} == ${filename} ]] && echo "Get ${filename}, skip." && fileflag="N"
    done < ${blklist}

    
    while read LINE
    do
        nowname=`echo ${LINE} | cut -d ' ' -f 1`
        [[ ${nowname} == ${filename} ]] && echo "already exist" && fileflag="N"
    done < ${listfile}

    if [ $fileflag = "Y" ];then
        filesize=`ls -lh ${filename} | cut -d ' ' -f 5`
        filesize="${filesize}B"
        filetime=`stat ${filename} | grep Modify | cut -d ' ' -f 2 | cut -d '.' -f 1`
        echo "${filename} ${filesize} ${filetime}" >> filelist.txt
        echo "Get ${filename} ${filesize} ${filetime}"
    fi
done
echo ""
echo "=====editing html====="
cp ${indexfile} index.html -f

while read LINE
do
    fname=`echo $LINE | cut -d ' ' -f 1`
    fsize=`echo $LINE | cut -d ' ' -f 2`
    ftime=`echo $LINE | cut -d ' ' -f 3`

    [[ ${fname} == "#" ]] && continue

    echo -e "\t\t\t<tr>" >> ${ihtml}
    echo -e "\t\t\t\t<td><a href=\"/d/${fname}\">${fname}</a></td>" >> ${ihtml}
    echo -e "\t\t\t\t<td>${fsize}</td>" >> ${ihtml}
    echo -e "\t\t\t\t<td>${ftime}</td>" >> ${ihtml}
    echo -e "\t\t\t</tr>" >> ${ihtml}
    echo " " >> ${ihtml}
    echo "Success: ${fname}"

done < filelist.txt

cat ${endfile} >> ${ihtml}

echo "html edit finish"

exit 0