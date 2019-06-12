#!/bin/bash
#for handling filename with space
#source =https://www.cyberciti.biz/tips/handling-filenames-with-spaces-in-bash.html
SAVEIFS=$IFS
IFS=$(echo -en "\n\b")
#for handling filename with space

if [[ $# == 0 ]]; then
	echo "This shell script compress all files with a specific extension"
    echo "Call syntax: archive [−s size] [−S sDir] [−d dDir] < ext_list >"
    echo "Example: archive -s 1000 -d ∼/oldFiles/ pdf doc exe"
    exit
fi
sizeLimit=0
sDir='./'
dDir=''
declare -a extensionList
#TODO : check if want to use * or @
#
##########READING ARGUMENTS #######################
while test $# -gt 0
do
	if [[ $1 = '-s' ]]; then
		shift
		#if no more arguments, then -s is given without size	
		if test $# -le 0; then
			echo "size not supplied"
			exit
		##check if next parameter starts with a '-', implies that the option is missing the argument
		elif [[ $1 == \-* ]]; then
			echo "size not supplied"
			exit
		else
			sizeLimit=$1
		fi
		shift
	elif [[ $1 = '-S' ]]; then
		shift
		if test $# -le 0; then
			echo "source directory not supplied"
			exit
		elif [[ $1 == \-* ]]; then
			echo "source directory not supplied"
			exit
		else
			sDir=$1
		fi
		shift
	elif [[ $1 = '-D' ]]; then
		shift
		if test $# -le 0; then
			echo "destination directory not supplied"
			exit
		elif [[ $1 == \-* ]]; then
			echo "destination directory not supplied"
			exit
		else
			dDir=$1
		fi
		shift
	else
		# if there exist an option which is unrecognized, say -l, then exit
		if [[ $1 == \-* ]]; then
			echo "unknown option"
			exit
		fi
	break
	fi
done
#if after shifting all options, parameter count is 0 => extension list is empty
if [[ $# == 0 ]]; then
	echo "parameter list missing extensions"
	exit
fi
for extn in "$@"
do
	extensionList=(${extensionList[@]} $extn)
done
if [[ $dDir = '' ]]; then
	dDir=$sDir
fi
#######DONE READING ARGUMENTS#####
#######checking if permission on source and destination folder###
if [[ -e $sDir && -r $sDir && -d $sDir ]]; then
	:
else
	echo "source folder does not exist or permission insuffiecient"
	exit
fi
if [[ -e $dDir && -w $dDir && -x $dDir && -d $dDir ]]; then
	:
else
	echo "destination folder does not exist or permission insuffiecient"
	exit
fi
if [[ -e $dDir/backUp || -e $dDir/backUp.tar ]]; then
	echo "backUp already exists..EXITING"
	exit
fi
#######done checking permission and exitistence of directories####
#######copy file one by one from source to destination####
cd $sDir
mkdir $dDir/backUp
for ext in  ${extensionList[@]} ; do
	if [ "$(ls *.$ext)" ]; then
		:
	else
		echo "no files for extension $ext..skipping"
		continue
	fi
	for file in `ls *.$ext`; do
		if [[ -r $file ]]; then
			:
		else
			echo "WARNING : file not copied as read permission mission on : $file"
			continue
		fi
		if [ -f $file ]; then
			if [[ $sizeLimit -gt 0 ]]; then
				size=`cat $file | wc -c`
				if [[ $size -gt $sizeLimit ]]; then
					cp $file $dDir/backUp
				fi
			else
				cp $file $dDir/backUp
			fi
		fi
	done
done
##########CREATE TAR AND DELETE OTHER FILES#######
cd $dDir/backUp
if [ "$(ls)" ]; then
	tar -cf ../backUp.tar *
else
	echo "no files found according to given criteria"
fi
cd ..
#DELETE BACKUP FOLDER
rm -rf backUp
echo "process complete"
####PROCESS COMPLETE#######
