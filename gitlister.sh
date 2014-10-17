#!/bin/bash

#Script to find git repositories when it becomes bit hard to keep track of cloned/modifed repos.
#does not handle space in path very well.
#takes $1 as root path to search, default= $PWD

#read location or use current dir
if [ "$1" ]; then location="$1"; else location="`pwd`"; fi;
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
		remote=(`git remote -v 2>/dev/null | grep "(fetch)"`);

		#print info
		echo "Found Repo: "$reponame;
		echo "Location: $PWD";
		echo "URL: ${remote[1]}";
	else
		echo "Location: $PWD";
		echo "Not a repo."
	fi;
	echo;
done;