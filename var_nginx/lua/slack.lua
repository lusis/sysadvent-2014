local shared_dict = ngx.shared.ng_shared_dict
local slack_token = shared_dict:get('slack_token')
local socket = require 'socket'
local hc = require 'httpclient'.new('httpclient.ngx_driver')
local cjson = require 'cjson'
local inspect = require 'inspect'
local ws = require 'resty.websocket.client'
local wsc, err = ws:new()

local function start_ws(url)
  local ok, err = wsc:connect(url)
  if not ok then
    ngx.say("failed to connect: "..err)
    return ngx.exit(444)
  end

  while true do
    local data, typ, err = wsc:recv_frame()
    if wsc.fatal then
      ngx.say("<br/>failed to recieve the frame: ", err)
      ngx.flush()
      return ngx.exit(444)
    end
    if not data then
      ngx.say("<br/>sending ping: ", typ)
      local bytes, err = wsc:send_ping()
      if not bytes then
        ngx.say("<br/>failed to send ping: ", err)
        return ngx.exit(444)
      end
    elseif typ == "close" then break
    elseif typ == "ping" then
      ngx.say("<br/>got ping: ", typ, "("..data..")")
      local bytes, err = wsc:send_pong()
      if not bytes then
        ngx.say("<br/>failed to send pong: ", err)
        return ngx.exit(444)
      end
    elseif typ == "text" then
      local ok, data_j = pcall(cjson.decode, data)
      if ok then
        if data_j['type'] == 'message' then
          ngx.say("[",data_j.channel,"] ", data_j.user,":", data_j.text, "<br/>")
        elseif data_j['type'] == 'hello' then
          ngx.say("Connected!<br/>")
        else
          ngx.say("<br/>unknown type: ", data)
        end
      end
    end
    ngx.flush()
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
