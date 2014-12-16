# SysAdvent 2014 - OpenResty, Nginx and Lua

This repository was designed to accompany my post for SysAdvent 2014. The contents of that post are also contained in the `sysadvent_post` directory.

The purpose of this is to not provide any canned application so much as to demonstrate the power and utility of having a full-fledged language like Lua inside Nginx. Many of the code samples are not the most efficient way of doing things and focus more on providing a clearer picture of exactly what exactly you can do with this combination. It goes without saying that you shouldn't attempt to run this anywhere other than locally.

## quick start
- clone this repo
- `make all`
- goto [http://127.0.0.1:3131/](http://127.0.0.1:3131)

This will start openresty in the foreground and clean up after itself. I've tested it mainly on Chrome + Linux. Specifically for the websocket stuff, Chrome is probably your best bet.

The reason for using a Makefile is to simplify the launch process. IF you want to run the commands manually, you can just look at the `Makefile`.

## Container contents
The container runs two services - `openresty` and `etcd`. Etcd exists only for one of the examples. The services are managed by `supervisord`.
The data used in the container is actual provided by a docker volume via the `var_nginx` directory. The reason behind this is to facilitate development and poking about.

### boot2docker users
I don't run boot2docker but my coworkers DID test this out on OSX boot2docker and claimed it worked. For windows users, I would love to have feedback.

### Log files
All log files will be written OUTSIDE of the container. The one of most interest is `var_nginx/logs/error.log`. This is where all lua logging goes.

# About the examples
The intention is that the examples progress from basic tricks to more interesting combinations.

## Connecting the code
Each example should provide a link or at least an explaination of the code being used.

## Etcd examples
The container ships with a copy of etcd running as well. When the container starts up, it will populate one backend node in etcd. There will be a button for you to populate the remaining 4 nodes.

The reason for the fixed number of backends to populate is that each of these backends are actually the local nginx listening on multiple ports so the config files must be precreated.

## Slack Websocket examples
To perform the slack websocket examples, you'll need a slack token for API calls. Then you'll want to restart the container with:

`DOCKER_ENV="--env SLACK_API_TOKEN=XXXXXXXXX" make run`

There are two examples of websockets in the repo:
- The first where nginx is acting as the websocket client and events are pushed to your browser using Server-sent events (which do not work on any version of IE)
- The second where your browser operates as the websocket client and nginx is the websocket server proxying content from the Slack RTM api

To use the second kind of example, you'll need a modern browser that has native websocket support.
