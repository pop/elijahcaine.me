#!/bin/bash
VENV='.venv'

git stash
rm -rf output/ .cache/

source $VENV/bin/activate

acrylamid compile -f

rm -rf /tmp/build_output
mv output /tmp/build_output

git checkout master

rm -rf ./*
mv /tmp/build_output/* ./

git add .
git commit -m "Site compiled on `date`"
git push -f origin master
git checkout source
git stash pop
