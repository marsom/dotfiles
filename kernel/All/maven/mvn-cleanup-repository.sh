#!/usr/bin/env bash

action="$1"
shift

for repo in "$@"; do
   if [ ! -d "$repo" ]; then
       echo "repo $repo does not exists"
       exit 1
   fi
   echo "cleaning $repo"
   while read basedir; do 
       if [ -f ${basedir}/maven-metadata.xml ] || [ -f ${basedir}/maven-metadata-local.xml ]; then
           latestversion=$(find $basedir | grep -v 'maven-metadata.*' | sort -n | grep '\.pom$' | tail -n1)
           latestversion=$(basename $latestversion .pom)

           # Delete everything, but the latest version and the maven metadata
           count=$(find ${basedir} -type f | grep -v -e 'maven-metadata.*' -e "$latestversion.*" -e ".*.properties" -e "_maven.repositories" | wc -l)
           size="0"
           if [ "$count" != "0" ]; then
               size=$(du -sc $(find ${basedir} -type f | grep -v -e 'maven-metadata.*' -e "$latestversion.*" -e ".*.properties" -e "_maven.repositories") | tail -n 1 | awk '{print $1}')
           fi
           case "$action" in
               cleanup)
                   echo "cleanup: $basedir count=$count size=$size"
                   find ${basedir} -type f | grep -v -e 'maven-metadata.*' -e "$latestversion.*" -e ".*.repositories" -e "_maven.repositories" | xargs -I{} rm '{}' 2>/dev/null
                   ;;
               *)
                   echo "dry-cleanup: $basedir count=$count size=$size"
                   ;;
           esac
       fi
   done < <(find $repo -type d 2>/dev/null | sort | awk '$0 !~ last "/" {print last} {last=$0} END {print last}' | grep "SNAPSHOT")
done