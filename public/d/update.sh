#!/bin/bash

listfile="filelist.txt"
indexfile="temp_index.html"
endfile="temp_index_end.html"
ihtml="index.html"
myname="update.sh"
blklist="blacklist.txt"
# get file list and write file info to filelist
echo "=====reading files====="
for filename in $(ls)
do
    fileflag="Y"
    echo -e "$filename :\t\c"
    # check blacklist, do not show these files.
    while read LINE
    do
        [[ ${LINE} == ${filename} ]] && echo "Get ${filename}, skip." && fileflag="N"
    done < ${blklist}

    # check file list, keep order
    while read LINE
    do
        nowname=`echo ${LINE} | cut -d ' ' -f 1`
        [[ ${nowname} == ${filename} ]] && echo "already exist" && fileflag="N"
    done < ${listfile}

    # write file-names to list
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

# read all files and write them to html
while read LINE
do
    fname=`echo $LINE | cut -d ' ' -f 1`
    fsize=`echo $LINE | cut -d ' ' -f 2`
    ftime=`echo $LINE | cut -d ' ' -f 3`

    # ignore first line
    [[ ${fname} == "#" ]] && continue

    echo -e "\t\t\t<tr>" >> ${ihtml}
    echo -e "\t\t\t\t<td><a href=\"/d/${fname}\">${fname}</a> </td><td> ... </td>" >> ${ihtml}
    echo -e "\t\t\t\t<td> ${fsize} </td><td> ... </td>" >> ${ihtml}
    echo -e "\t\t\t\t<td> ${ftime} </td>" >> ${ihtml}
    echo -e "\t\t\t</tr>" >> ${ihtml}
    echo " " >> ${ihtml}
    echo "Success: ${fname}"

done < filelist.txt

# write last part of html
cat ${endfile} >> ${ihtml}

echo "html edit finish"

exit 0