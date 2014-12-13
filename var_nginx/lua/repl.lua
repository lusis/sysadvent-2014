ngx.req.read_body()
local args = ngx.req.get_post_args()
local cmd = args['cmd'] or nil

if cmd == '' or not cmd then
  ngx.header.content_type = 'text/plain'
  ngx.say("you gotta specify a command dude")
  ngx.exit(ngx.OK)
else
  -- some helpful libraries to add to the repl environment
  local inspect = require 'inspect'
  local cjson = require 'cjson'
  local hc = require 'httpclient'.new('httpclient.ngx_driver')
  local f, msg = load(cmd, nil, 't', {ngx = ngx, inspect = inspect, cjson = cjson, ['pairs'] = pairs, ['ipairs'] = ipairs, hc = hc})

  ngx.header.content_type = 'text/plain'
  if not f then
    ngx.status = 400
    ngx.log(ngx.INFO,"Error loading function: ", inspect(msg))
    ngx.say(msg)
    ngx.exit(ngx.HTTP_OK)
  else
    local ok, msg = pcall(f)
    if not ok then
      ngx.status = 400
      ngx.say(msg)
      ngx.exit(ngx.HTTP_OK)
    else
      if type(msg) == "function" then
        ngx.say("Maybe you meant: ", cmd,"()")
        ngx.exit(ngx.HTTP_OK)
      else
        ngx.say(msg)
        ngx.exit(ngx.HTTP_OK)
      end
    end
  end
end
