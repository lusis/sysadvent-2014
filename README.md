# SysAdvent 2014 - OpenResty, Nginx and Lua

## quick start
- clone this repo
- `make all`
- goto [http://127.0.0.1:3131/](http://127.0.0.1:3131)

This will start openresty in the foreground and clean up after itself.

### boot2docker users
I don't run boot2docker but my coworkers DID test this out on OSX boot2docker and claimed it worked. For windows users, I would love to have feedback.
Note that the container, when started, mounts the `var_nginx` directory inside the container as `/var/nginx` so that may impact usage.

### Log files
All log files will be written OUTSIDE of the container. The one of most interest is `var_nginx/logs/error.log`. This is where all lua logging goes.

### Websocket examples
To perform the websocket examples, you'll need a slack token for API calls. Then you'll want to restart the container with:

`DOCKER_ENV="--env SLACK_API_TOKEN=XXXXXXXXX" make run`

### Etcd examples
To perform the etcd example, you'll need to have an external etcd instance to talk to (no authentication is supported). The makefile offers support for running an etcd container.
If you want to use run etcd via the makefile, You'll your system's ip address as nginx will contact etcd at that ip address. localhost will not work in this case:
```
PUBLIC_IP="your local ip" make etcd
```

Then you can run the openresty container in another window like so:
```
DOCKER_ENV="--env ETCD_URL="http://<ip from above>:5001"' make run
```

Once you load the etc example in the container, you will probably be faced with no data. There's another make command (`etcd_populate`) that will add a bunch of keys to etcd under the expected namespace. Alternately you can just run:

```
for i in `seq 10 30`;do curl -Ls -XPUT -d value="192.168.1.${i}:80${i}" http://etcdhost:etcdport/v2/keys/lbs/backends/node${i}; sleep 2; done
```

You should see the data start filling up the table in your browser as it is added.
