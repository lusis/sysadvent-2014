local bootstrap = [[
<!DOCTYPE html>
<html>
<head>
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.1/css/bootstrap.min.css">
<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.1/css/bootstrap-theme.min.css">
<style>
body {
  padding-top: 50px;
}
.content {
  padding: 40px 15px;
}
label {
  padding: 5px;
}
</style>
<script src="//code.jquery.com/jquery-1.9.1.js"></script>
<script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.1/js/bootstrap.min.js"></script>
<script src="//cdnjs.cloudflare.com/ajax/libs/underscore.js/1.7.0/underscore-min.js"></script>
<script src="//google-code-prettify.googlecode.com/svn/loader/run_prettify.js"></script>
<script src="//google-code-prettify.googlecode.com/svn/trunk/src/lang-lua.js"></script>
<script src='/js/lb.js'></script>
<title>Welcome SysAdvent</title>
</head>
<body onload='return connect();'>

    <nav class="navbar navbar-inverse navbar-fixed-top" role="navigation">
      <div class="container">
        <div class="navbar-header">
          <button type="button" class="navbar-toggle collapsed" data-toggle="collapse" data-target="#navbar" aria-expanded="false" aria-controls="navbar">
            <span class="sr-only">Toggle navigation</span>
            <span class="icon-bar"></span>
            <span class="icon-bar"></span>
            <span class="icon-bar"></span>
          </button>
          <a class="navbar-brand" href="#">SysAdvent 2014</a>
        </div>
        <div id="navbar" class="collapse navbar-collapse">
          <ul class="nav navbar-nav">
            <li><a href="/">Home</a></li>
            <li><a href="/docs/index.md">Docs</a></li>
            <li><a href="/docs/cookbook.md">Cookbook</a></li>
            <li><a href="https://github.com/lusis/sysadvent-2014">Github Repo for this project</a></li>
          </ul>
        </div><!--/.nav-collapse -->
      </div>
    </nav>

    <div class="container">
]]

local lbs = ngx.shared.ng_loadbalancers


if ngx.var.arg_sddelete then
  lbs:delete(ngx.unescape_uri(ngx.var.arg_sddelete))
  ngx.redirect("/load_balancer")
end

ngx.say(bootstrap)
ngx.say("Backends<br/>")
ngx.say("<table id='loadbalancers' class='display' cellspacing='0' width='100%'")
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
ngx.say(bootstrap_footer)
ngx.exit(ngx.OK)
