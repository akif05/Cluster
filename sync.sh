#!/bin/bash
# Adding all files and pushing ot git repo
# Need to be provied with comment and directory
# Example: sync.sh /Users/akifyusein/PycharmProjects "My comment"

if [ $# -ne 2 ]; then
  echo "Provide comment and directory before pushing to master!"
  echo $#
  exit
fi

if [ ! -d "$1" ]; then
  echo "Directory $1 not exist."
  exit
fi

# Cd to directory which needs to be pushed to git reposytory
cd $1

git add -A
git commit -a -m "$2"
git push -u origin master
