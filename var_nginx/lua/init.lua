-- These variables are all local to this file
local users_dict = ngx.shared.ng_users_dict
local shared_dict = ngx.shared.ng_shared_dict
local hc = require 'httpclient'.new()
local startup_time = ngx.utctime()
local json_blob = [[{"username":"sysadvent", "password":"supersecret"}]]
-- Set some data in the shared dictionaries
-- these are visible across workers
shared_dict:set("startup_time", startup_time)
users_dict:set("sysadvent", json_blob)
shared_dict:set("slack_token", os.getenv("SLACK_API_TOKEN"))
shared_dict:set("etcd_url", os.getenv('ETCD_URL'))
-- This is a global variable across all workers
-- a common html header for bootstrap
bootstrap_header = [[
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
<link rel="styelsheet" href="//cdn.datatables.net/plug-ins/9dcbecd42ad/integration/bootstrap/3/dataTables.bootstrap.css">
<script src="//code.jquery.com/jquery-1.9.1.js"></script>
<script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.1/js/bootstrap.min.js"></script>
<script src="//cdnjs.cloudflare.com/ajax/libs/underscore.js/1.7.0/underscore-min.js"></script>
<script src="//cdn.datatables.net/1.10.4/js/jquery.dataTables.min.js"></script>
<script src="//cdn.datatables.net/plug-ins/9dcbecd42ad/integration/bootstrap/3/dataTables.bootstrap.js"></script>
<script src="//google-code-prettify.googlecode.com/svn/loader/run_prettify.js"></script>
<script src="//google-code-prettify.googlecode.com/svn/trunk/src/lang-lua.js"></script>
<title>Welcome SysAdvent</title>
</head>
<body>

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
            <li><a href="https://github.com/lusis/sysadvent-2014">Github Repo for this project</a></li>
          </ul>
        </div><!--/.nav-collapse -->
      </div>
    </nav>

    <div class="container">

]]
-- now the common footer
bootstrap_footer = [[
</div> <!-- container -->
</body>
</html>
]]
