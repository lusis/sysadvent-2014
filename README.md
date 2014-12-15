# SysAdvent 2014 - OpenResty, Nginx and Lua

## quick start
- clone this repo
- `make all`
- goto [http://127.0.0.1:3131/](http://127.0.0.1:3131)

This will start openresty in the foreground and clean up after itself. I've tested it mainly on Chrome + Linux. Specifically for the websocket stuff, Chrome is probably your best bet.

### boot2docker users
I don't run boot2docker but my coworkers DID test this out on OSX boot2docker and claimed it worked. For windows users, I would love to have feedback.
Note that the container, when started, mounts the `var_nginx` directory inside the container as `/var/nginx` so that may impact usage.

### Log files
All log files will be written OUTSIDE of the container. The one of most interest is `var_nginx/logs/error.log`. This is where all lua logging goes.

## Websocket examples
To perform the websocket examples, you'll need a slack token for API calls. Then you'll want to restart the container with:

`DOCKER_ENV="--env SLACK_API_TOKEN=XXXXXXXXX" make run`

There are two examples of websockets in the repo:
- The first where nginx is acting as the websocket client for you and returning regular text
- The second where your browser operates as the websocket client and nginx is the websocket server

To use the second kind of example, you'll need a modern browser that has native websocket support.

### Etcd examples
The container ships with a copy of etcd running as well. When the container starts up, it will populate one backend node in etcd. There will be a button for you to populate the remaining 4 nodes.

The reason for the fixed number of backends to populate is that each of these backends are actually the local nginx listening on multiple ports so the config files must be precreated.

