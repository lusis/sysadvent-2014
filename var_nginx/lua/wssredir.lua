local shared_dict = ngx.shared.ng_shared_dict
local slack_token = shared_dict:get('slack_token')
local socket = require 'socket'
local hc = require 'httpclient'.new('httpclient.ngx_driver')
local cjson = require 'cjson'
local inspect = require 'inspect'
local template = require 'resty.template'
template.caching(false)
local params = {}

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
    template.render("wss.html", {params = {data = res.body, url = proxy_url, ngx = ngx }})
  end
end

start_rtm()
