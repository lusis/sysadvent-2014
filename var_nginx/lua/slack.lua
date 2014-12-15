local shared_dict = ngx.shared.ng_shared_dict
local slack_token = shared_dict:get('slack_token')
local socket = require 'socket'
local hc = require 'httpclient'.new('httpclient.ngx_driver')
local cjson = require 'cjson'
local inspect = require 'inspect'
local ws = require 'resty.websocket.client'
local wsc, err = ws:new()
local body

if not slack_token then
  ngx.say("data: Gotta set a slack token\n\n")
  ngx.exit(ngx.OK)
end

local function start_ws(url)
  local ok, err = wsc:connect(url)
  ngx.header.content_type = 'text/event-stream'
  if not ok then
    ngx.say("data: [failed to connect] "..err.."\n\n")
    return ngx.exit(ngx.HTTP_OK)
  end

  while true do
    local data, typ, err = wsc:recv_frame()
    if wsc.fatal then
      ngx.say("data: [failed to recieve the frame] ", err,"\n\n")
      ngx.flush()
      return ngx.exit(ngx.HTTP_OK)
    end
    if not data then
      ngx.say("data: [sending ping] ", typ)
      local bytes, err = wsc:send_ping()
      if not bytes then
        ngx.say("data: [failed to send ping] ", err,"\n\n")
        return ngx.exit(ngx.HTTP_OK)
      end
    elseif typ == "close" then break
    elseif typ == "ping" then
      ngx.say("data: [got ping] ", typ, "("..data..")\n\n")
      local bytes, err = wsc:send_pong()
      if not bytes then
        ngx.say("data: [failed to send pong] ", err,"\n\n")
        return ngx.exit(ngx.HTTP_OK)
      end
    elseif typ == "text" then
      local ok, data_j = pcall(cjson.decode, data)
      if ok then
        if data_j['type'] == 'message' then
          ngx.say("data: [",data_j.channel,"] ", data_j.user," ", data_j.text,"\n\n")
        elseif data_j['type'] == 'hello' then
          ngx.say("data: Connected!\n\n")
        else
          ngx.say("data: [unknown type] ", data, "\n\n")
        end
      end
    end
    ngx.flush(true)
  end
end

local function start_rtm()
  local res, err = hc:get('https://slack.com/api/rtm.start?token='..slack_token)
  if err then
    ngx.log(ngx.ERR,'failed to connect to slack: '..err)
  else
    local data = cjson.decode(res.body)
    ngx.log(ngx.ERR, "WSS URL: ", data.url)
    local rewrite_url_t = hc:urlparse(data.url)
    -- proxy_pass doesn't understand ws[s] urls so we fake it
    local rewrite_url = "https://"..rewrite_url_t.host..rewrite_url_t.path
    local proxy_url = 'ws://127.0.0.1:3131/wssproxy?url='..rewrite_url
    ngx.log(ngx.ERR, "Proxy URL: ", proxy_url)
    start_ws(proxy_url)
  end
end

start_rtm()
