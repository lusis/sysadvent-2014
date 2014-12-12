ngx.req.read_body()
local inspect = require 'inspect'
local args = ngx.req.get_post_args()
local cmd = args['cmd'] or nil

ngx.log(ngx.INFO, "Passed cmd to repl: ", inspect(args))
if cmd == '' or not cmd then
  ngx.header.content_type = 'text/plain'
  ngx.say("you gotta specify a command dude")
  ngx.exit(ngx.OK)
else
  ngx.header.content_type = 'text/plain'

  local func = "return "..cmd
  local f, msg = load(func, nil, 't')
  if not f then 
    ngx.log(ngx.INFO,"Error loading function: ", inspect(msg))
    ngx.say("Error running code: ", msg)
    ngx.exit(ngx.OK)
  else
    local ok, msg = pcall(f)
    if not ok then
      ngx.say("Command returned an error: ",msg)
    else
      if type(msg) == "function" then
        ngx.say("Maybe you meant: ", cmd,"()")
      else
        ngx.say(inspect(msg))
      end
      ngx.exit(ngx.OK)
    end
  end
end
