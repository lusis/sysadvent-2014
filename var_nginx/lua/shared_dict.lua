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

local shared_dict = ngx.shared.ng_shared_dict


if ngx.var.arg_sddelete then
  shared_dict:delete(ngx.unescape_uri(ngx.var.arg_sddelete))
  ngx.redirect("/shared_dict")
end

if ngx.var.arg_sdkey and ngx.var.arg_sdvalue then
  local k = ngx.unescape_uri(ngx.var.arg_sdkey)
  local v = ngx.unescape_uri(ngx.var.arg_sdvalue)
  shared_dict:set(k, v)
end

ngx.say(bootstrap)
local keys = shared_dict:get_keys()
if #keys < 1 then
  ngx.say("we found no keys in the shared dictionary")
else
  ngx.say("The following keys and values were set in the nginx shared lua dictionary.<br/>These keys do not persist through hard bounces but do persist through reloads<br/>")
  ngx.say("<table style='border-spacing: 5px; width: 25%; border: 1px solid; padding: 5px;'>")
  for k, v in pairs(keys) do
    ngx.say("<tr>")
    ngx.say("<td style='border: 1px solid black; text-align: center;'>",v, "</td>")
    ngx.say("<td style='border: 1px solid black; text-align: center;'>",shared_dict:get(v),"</td>")
    ngx.say("<td style='border: 1px solid black; text-align: center;'><a href=/shared_dict?sddelete="..v..">Delete this entry</a></td>")
    ngx.say("</tr>")
  end
  ngx.say("</table><br/>")
end
local form = [[<form action="/shared_dict" style='padding: 4px; margin:1px; background: #eee; width: 25%;'>Add some data to the shared dictionary:
  <br/><label style='display:inline-block; width:120px; margin-left:5px;'>key</label> <input type="text" name="sdkey" style='display:inline-block;'>
  <br/><label style='display:inline-block; width:120px; margin-left:5px;'>value</label> <input type="text" name="sdvalue" style='display:inline-block;'>
  <br/><input type="submit" style='display:inline-block;'></form>"]]
ngx.say(form)
ngx.say("</body></html>")
ngx.exit(ngx.OK)
