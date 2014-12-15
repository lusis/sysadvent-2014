#!/usr/bin/env bash
sleep 5
curl -Ls -XPUT -d value=127.0.0.1:3141 http://127.0.0.1:5001/v2/keys/lbs/backends/node1
#curl -Ls -XPUT -d value=127.0.0.1:3142 http://127.0.0.1:5001/v2/keys/lbs/backends/node2
#curl -Ls -XPUT -d value=127.0.0.1:3143 http://127.0.0.1:5001/v2/keys/lbs/backends/node3
#curl -Ls -XPUT -d value=127.0.0.1:3144 http://127.0.0.1:5001/v2/keys/lbs/backends/node4
#curl -Ls -XPUT -d value=127.0.0.1:3145 http://127.0.0.1:5001/v2/keys/lbs/backends/node5
