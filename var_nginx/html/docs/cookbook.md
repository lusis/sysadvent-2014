# OpenResty Cookbook
This is a small set of examples of places you might want to leverage lua integration

## Reading the nginx lua docs
Reading the lua documentation can be a bit frustrating but understanding where each function or variable is allowed is very important. It's also important to understand the various Nginx phases of how a request is handled and contexts. Let's look at the documentation for [`log_by_lua*`](http://wiki.nginx.org/HttpLuaModule#log_by_lua):

```
log_by_lua
syntax: log_by_lua <lua-script-str>
context: http, server, location, location if
phase: log
```

This says that the directive is allowed in `http`,`server` and `location` blocks. Attempts to use it anywhere else will throw an error.
Additionally it happens at the `log` phase (which is the next to last phase a request goes through).

It's also important to note that the lua module itself may prevent other lua functionality inside this function. In the case of `log_by_lua`, you aren't allowed any of the following:

- Output API functions (e.g., `ngx.say` and `ngx.send_headers`)
- Control API functions (e.g., `ngx.exit`)
- Subrequest API functions (e.g., `ngx.location.capture` and `ngx.location.capture_multi`)
- Cosocket API functions (e.g., `ngx.socket.tcp` and `ngx.req.socket`).

The reasons things can be disallowed are because either they're irrelevant (you can't send anymore data to the client at this point because the request is closed) or because they could block the worker.


## Global State
In general you should minimize the amount of global state, however there are cases where you really have state that's shared across all users. Usually it's global variables or places where you have global modules that should be safe.

### [init\_by\_lua](http://wiki.nginx.org/HttpLuaModule#init_by_lua)
Lua executed in this area lives in the master nginx process. It is shared across all workers. A good example of something you might want to set here are shared credentials or a common require across all workers:

```lua
-- this require will be local to this lua file
local foo = require 'bar'
-- this require will be global
-- it will allow you to use cjson.decode everywhere
-- without requiring it first
cjson = require 'cjson'
-- this makes slack_token a global variable set from the env var SLACK_API_TOKEN
slack_token = os.getenv("SLACK_API_TOKEN"))
```

This is also the place where you should set any global data in shared dictionaries. Take the following nginx config statement from the `01-lua` config file in this repo:

```
lua_shared_dict ng_shared_dict 20m;
lua_shared_dict ng_users_dict 20m;
lua_shared_dict ng_shared_locks 100k;
lua_shared_dict ng_loadbalancers 100k;
```

Here we are creating a bunch of [shared dictionaries](/shared_dict). In our `init_by_lua_file`, we add some initial data to it:

```lua
local users_dict = ngx.shared.ng_users_dict
local shared_dict = ngx.shared.ng_shared_dict
local startup_time = ngx.utctime()
local json_blob = '{"username":"sysadvent", "password":"supersecret"}'
-- Set some data in the shared dictionaries
-- these are visible across workers
shared_dict:set("startup_time", startup_time)
users_dict:set("sysadvent", json_blob)
```

This means that any worker can call `ngx.shared.ng_users_dict:get("startup_time")` for instance and get the value set in the init.

There is also a `init_worker_by_lua*` that does the same thing (runs every time a worker is started).

## Cookie manipulation
While most codebases should honor the `X-Forwarded-Proto` header to ensure that cookies have the `Secure` flag and are `HttpOnly`, that doesn't always happen.

One of the handy lua options is [header\_filter\_by\_lua\*](http://wiki.nginx.org/HttpLuaModule#header_filter_by_lua). This allows you to manipulate response headers before they're sent out.

You can see an example of this in the `var_nginx/conf.d/be1.conf`:

```
location / {
	content_by_lua '
		local node_number = 1
		local template = require "resty.template"
		template.caching(false)
		ngx.header["x-ngx-be"] = "node"..node_number
		ngx.header["Set-Cookie"] = "foo=bar; path=/"
		template.render("benode.html", { ngx = ngx, node_number = node_number })
	';
}
```

In the above we set the the cookie `foo` however we don't set it to `HttpOnly` or `Secure`. We can fix this in the location where we call this backend:

```
header_filter_by_lua '
	local inspect = require "inspect"
	local cookies = ngx.header.set_cookie
	if not cookies then return end
	if type(cookies) ~= "table" then cookies = {cookies} end
	local newcookies = {}
	for i, val in ipairs(cookies) do
	if not string.find(val, "HttpOnly") then
	  ngx.log(ngx.INFO, "Cookie from backend is not HttpOnly. Fixing up")
	  val = val..";HttpOnly"
	end
	table.insert(newcookies, val)
	end
	ngx.log(ngx.INFO, "Final cookie: ", inspect(newcookies))
	ngx.header.set_cookie = newcookies
';
```

Note that `ngx.header.set_cookie` requires a table of strings (i.e. `{ cookie1, cookie2, cookie3 }`. Here we iterate through all the cookies we find (they will be automatically restricted to the domain we are using). It's also important to remember that lua does shallow copies, hence inserting into a new table.
