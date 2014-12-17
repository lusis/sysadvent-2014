# OpenResty Tutorial
Welcome to the OpenResty tutorial container documentation.

## About these docs
These docs themselves are markdown files parsed by the [lua-resty-template markdown parser](https://github.com/bungle/lua-resty-template#embedding-markdown-inside-the-templates)

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
This project was created to accompany an entry in the SysAdvent series of posts for 2014. The [original post is here](https://sysadvent.blogspot.com/??????).
It is intended to serve as a demonstration of the capabilities of the [OpenResty](http://openresty.org) build of [Nginx](http://nginx.org).
