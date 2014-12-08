local bootstrap = [[
<!DOCTYPE html>
<html>
<head>
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.1/css/bootstrap.min.css">
<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.1/css/bootstrap-theme.min.css">
<script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.1/js/bootstrap.min.js"></script>
<title>Welcome SysAdvent</title>
</head>
<body>
]]
-- if we don't have any params, we display a form
local form = [[<form action="/github">Enter a username to find on github: <input type="text" name="username"><br/><input type="submit"></form>"]]
local username = ngx.var.arg_username
if not username then
  ngx.say(bootstrap)
  ngx.say(form)
  ngx.say("</body></html>")
  ngx.exit(ngx.OK)
end

-- We need to clear all the headers otherwise nginx will proxy our request headers through which we don't want here:
local bh = ngx.req.get_headers()
  for k, v in pairs(bh) do
    ngx.req.clear_header(k)
end
-- set our request headers. Github requires a user-agent
ngx.req.set_header("Content-Type", "application/json")
ngx.req.set_header("Accept", "application/json")
ngx.req.set_header("User-Agent", "sysadvent 2014 openresty ".. ngx.now())
-- ngx
local res = ngx.location.capture("/capture", { method = ngx.HTTP_GET, args = {url = "https://api.github.com/users/"..username}})
if not res then
  ngx.say("Something went goofy talking to github")
  ngx.exit(ngx.OK)
else
  -- set our response header
  ngx.header.content_type = "application/json"
  ngx.say(res.body)
  ngx.exit(ngx.OK)
end
