#!/bin/bash

##############
# DLLProx.sh #
##############

if [ -z $1 ]; then
	echo "Usage : $0 <path_to_DLL> [--system32]"
	echo "Option --system32 allows to specify that the original DLL comes from C:\\Windows\\System32"
else

	isSys32=$2
	if [ -z $isSys32 ];then
		isSys32="NULL"
	fi

	path=$1

	filename=$(basename $path)

	winepath="/home/$USER/.wine/drive_c/users/$USER/$filename"

	dllexp_path="C:\\users\\$USER\\$filename"

	cp $path $winepath

	wine ressources/dllexp.exe /from_files $dllexp_path /shtml outputs/report_$filename.html

	if [ $isSys32 == "--system32" ];then
		python ressources/report_extract.py outputs/report_$filename.html --system32
	else
		python ressources/report_extract.py outputs/report_$filename.html
	fi

# Uncomment these if the script never shows any functions

#	echo ""
#	echo ""
#	echo "If nothing shows up it means that dllexp.exe has found no function in your DLL, or isn't working properly."
#	echo "If so, please try wine $(pwd)/ressources/dllexp.exe /from_files $dllexp_path /shtml report.html on your own"
#	echo ""

fi
