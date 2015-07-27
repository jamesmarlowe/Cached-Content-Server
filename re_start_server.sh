#!/bin/bash

clear

echo "stopping nginx"
sudo /usr/local/openresty/nginx/sbin/nginx -s stop -p `pwd`
sudo killall nginx

echo "removing nginx logs"
sudo rm logs/*.log

echo "recompiling lua files"
for f in $(find rocks -name '*.lua')
do
  echo "compiling " $f
  /usr/local/openresty/luajit/bin/luajit-2.1.0-alpha -bg $f ${f/%.lua/.luac}
done

echo "starting nginx from conf/nginx$1.conf"
sudo /usr/local/openresty/nginx/sbin/nginx -c conf/nginx$1.conf -p `pwd`

echo "calling health-check"
curl localhost/health/
