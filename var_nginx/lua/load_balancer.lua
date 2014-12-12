local bootstrap = [[
<!DOCTYPE html>
<html>
<head>
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.1/css/bootstrap.min.css">
<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.1/css/bootstrap-theme.min.css">
<link rel="styelsheet" href="//cdn.datatables.net/plug-ins/9dcbecd42ad/integration/bootstrap/3/dataTables.bootstrap.css">
<script src="//code.jquery.com/jquery-1.9.1.js"></script>
<script src="//maxcdn.bootstrapcdn.com/bootstrap/3.3.1/js/bootstrap.min.js"></script>
<script src="//cdnjs.cloudflare.com/ajax/libs/underscore.js/1.7.0/underscore-min.js"></script>
<script src="//cdn.datatables.net/1.10.4/js/jquery.dataTables.min.js"></script>
<script src="//cdn.datatables.net/plug-ins/9dcbecd42ad/integration/bootstrap/3/dataTables.bootstrap.js"></script>
<script src="/js/lb.js"></script>
<title>SysAdvent Load Balancer Management</title>
</head>
<body onload="return connect();">
]]

local lbs = ngx.shared.ng_loadbalancers


if ngx.var.arg_sddelete then
  lbs:delete(ngx.unescape_uri(ngx.var.arg_sddelete))
  ngx.redirect("/load_balancer")
end

ngx.say(bootstrap)
ngx.say("Backends<br/>")
ngx.say("<table id='loadbalancers' class='display' cellspacing='0' width='100%'>")
ngx.say("<thead><tr>")
ngx.say("<th>backend</th>")
ngx.say("<th>address</th>")
  --ngx.say("<td style='border: 1px solid black; text-align: center;'><a href=/load_balancer?sddelete="..v..">Disable this backend</a></td>")
ngx.say("</tr></thead>")
ngx.say("</table><br/>")

local form = [[<form action="/load_balancer" style='padding: 4px; margin:1px; background: #eee; width: 25%;'>Add some data to the shared dictionary:
  <br/><label style='display:inline-block; width:120px; margin-left:5px;'>key</label> <input type="text" name="sdkey" style='display:inline-block;'>
  <br/><label style='display:inline-block; width:120px; margin-left:5px;'>value</label> <input type="text" name="sdvalue" style='display:inline-block;'>
  <br/><input type="submit" style='display:inline-block;'></form>"]]
--ngx.say(form)
ngx.say("</body></html>")
ngx.exit(ngx.OK)
