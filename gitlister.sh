#!/bin/bash

#script to find git repositories when it becomes hard to keep track of all git repositories
#takes $1 as root path to search, default= $PWD

# argumnet -diff checks if any of the gits are modified locally
# argumnet -url checks if any of the gits are modified locally
# both arguments are enabled by default so use -nodiff, -nourl

#read location or use current dir
if [ "$1" ]; then location="$1"; #else location="`pwd`"; fi;
else
	echo "Description:";
	echo "Find git repositories inside given directory / filesystem.";
	echo "Also shows modified status, and remote URL.";
	echo;
	echo "Usage:";
	echo "sh $0 /path/to/search [-nodiff, -nourl]";
	exit;
fi;

#check if option for checking for diff enabled 
checkdiff=true; #enabled by default
if [ "`echo "$@" | grep -iosw \"\-nodiff\"`" ]; then checkdiff=false; fi;

#show fetch remotes
showurl=true; #enabled by default
if [ "`echo "$@" | grep -iosw \"\-nourl\"`" ]; then showurl=false; fi;

#read absolute location
location="`readlink -f $location`";
echo "location: $location";
echo;

#find all .git folders in location
gitlist=(`find $location -type d -name ".git" | sort`);
#readarray gitlist < `find $location -type d -name ".git"`;
for index in ${!gitlist[@]};
do
	#enter repodir
	cd "$location";
	gitdir="${gitlist[$index]}";
	repodir="${gitdir%/*}";
	#check if actually a repo or just a dir
	cd "$repodir";
	if [ "`git rev-parse --is-inside-work-tree 2>/dev/null`" == true ];
	then
		reponame="`basename $repodir`";
		#show remote / grep fetch link
		if [ $showurl ];
		then
			remote=(`git remote -v 2>/dev/null | grep "(fetch)"`);
		fi;
		#diff status check
		if [ $checkdiff ];
		then
			diffstatus="`git diff --exit-code > /dev/null && echo 0 || echo 1`";
			#echo $diffstatus;
		fi;

		#print info (in color!)
		[[ "$diffstatus" == "1" ]] && echo -e "\033[32m[MODIFIED]\033[0m";
		echo "Found Repo: "$reponame;
		echo "Location: $PWD";
		[[ $showurl ]] && echo "Remote: ${remote[1]}";
	else
		echo "Location: $PWD";
		echo "Not a repo."
	fi;
	echo;
done;
