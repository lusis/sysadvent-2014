# About this project

## How this works
The various examples on the main page are actually created using the lua functionality they demonstrate. For instance the `content_by_lua` example, is actually created by an nginx `content_by_lua` directive.

Many examples also include a link to display the source of the lua file rendering the page inline

## About the docs section
This page (and anything in the docs directory) are markdown files parsed by the [lua-resty-template markdown parser](https://github.com/bungle/lua-resty-template#embedding-markdown-inside-the-templates)

### nginx location block
```lua
location /docs {
  set $template_root '/var/nginx/html/docs';
  content_by_lua_file "/var/nginx/lua/markdown.lua";
}
```
### lua renderer source
Lua source for `markdown.lua` is available [here](/code/lua/markdown.lua)

## About this project
This project was created to accompany an entry in the SysAdvent series of posts for 2014. The [original post is here](http://sysadvent.blogspot.com/2014/12/day-22-largely-unappreciated.html).
It is intended to serve as a demonstration of the capabilities of the [OpenResty](http://openresty.org) build of [Nginx](http://nginx.org).
