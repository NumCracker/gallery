#!/bin/bash
cd `dirname $0`
cp /var/pictures/pictures/index.html web/ 
cp /var/pictures/pictures/spinner.gif web/ 
cp /var/pictures/pictures/*.js web/ 

cp /usr/local/nginx/conf/nginx.conf nginx/conf
cp /usr/local/nginx/perl/lib/*.pm nginx/perl-lib/
git add `find . -type f |grep -v git`
git commit -m 'some stuff'
git push -u origin master
