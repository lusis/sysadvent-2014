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
local info = debug.getinfo(1,'S');
local username = ngx.var.arg_username or "Anonymous"
ngx.say(bootstrap)
ngx.say("<p/>Hello, ", username, ". Welcome to openresty. This content comes from:")
ngx.say("<p>", info.source)
ngx.say("<p/>Maybe you wanted to log in as a user? <a href=/content_by_lua_file/?username=sysadvent>Click here!</a>")
ngx.say("</body></html>")
ngx.exit(ngx.OK)
