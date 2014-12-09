# SysAdvent 2014 - OpenResty, Nginx and Lua

## quick start
- clone this repo
- `make all`
- goto [http://127.0.0.1:3131/](http://127.0.0.1:3131)

This will start openresty in the foreground and clean up after itself.

### boot2docker users
I don't run boot2docker but my coworkers DID test this out on OSX boot2docker and claimed it worked. For windows users, I would love to have feedback.
Note that the container, when started, mounts the `var_nginx` directory inside the container as `/var/nginx` so that may impact usage.

### Websocket examples
To perform the websocket examples, you'll need a slack token for API calls. Then you'll want to restart the container with:

`DOCKER_ENV="--env SLACK_API_TOKEN=XXXXXXXXX" make run`


