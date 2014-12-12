local log = ngx.log
local sleep = ngx.sleep
local cjson = require 'cjson'
local encode = cjson.encode
local decode = cjson.decode
local lbs = ngx.shared.ng_loadbalancers
local server = require "resty.websocket.server"
local wb, err = server:new()
if not wb then
  log(ngx.ERR, "failed to start websocket server: ", err)
  return ngx.exit(444)
end

local bytes, err = wb:send_text('connected')
if not bytes then
  log(ngx.ERR, "failed to send 1st bytes: ", err)
  return ngx.exit(444)
end

while true do
  local state = lbs:get_keys()
  local d = {}
  for k, v in pairs(state) do
    d[v] = lbs:get(v)
  end
  local bytes, err = wb:send_text(encode(d))
  if not bytes then
    ngx.log(ngx.ERR, "failed to send the current state: ", err)
    return ngx.exit(444)
  end
  sleep(5)
  local pb, pe = wb:send_ping()
  if not pb then
    ngx.log(ngx.ERR, "failed to send the ping: ", err)
  end
  local data, typ, err = wb:recv_frame()
  if not data then
    log(ngx.ERR, "failed to recieve a frame: ", err)
    return ngx.exit(444)
  elseif typ == "close" then
    break
  elseif typ == "ping" then
    local bytes, err = wb:send_pong()
    if not bytes then
      ngx.log(ngx.ERR, "failed to send pong ", err)
      return ngx.exit(444)
    end
  elseif typ == "pong" then
    ngx.log(ngx.INFO, "client ponged")
  elseif typ == "text" then
    ngx.log(ngx.INFO, "ignore msg from client: ", data)
  else
    ngx.log(ngx.INFO, "unknown type from client: ", typ, " with data: ", data)
  end
end
