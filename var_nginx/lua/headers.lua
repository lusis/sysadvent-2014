local cjson = require 'cjson'
local inspect = require 'inspect'
ngx.say(bootstrap_header)
local all_headers = {}
all_headers.request_headers = ngx.req.get_headers()
all_headers.response_headers = ngx.resp.get_headers()
ngx.say("<div class='content-request'><p><label>Request Headers</label></p>")
ngx.say("<div><pre class='prettyprint'><code class='lang-lua'>"..inspect(all_headers.request_headers).."</code></pre></div>")
ngx.say("</div>")
ngx.say("<div class='content-response'><p><label>Response Headers</label></p>")
ngx.say("<div><pre class='prettyprint'><code class='lang-lua'>"..inspect(all_headers.response_headers).."</code></pre></div>")
ngx.say("</div>")
local this_file = [[
local cjson = require 'cjson'
local inspect = require 'inspect'
ngx.say(bootstrap_header)
local all_headers = {}
all_headers.request_headers = ngx.req.get_headers()
all_headers.response_headers = ngx.resp.get_headers()
ngx.say(inspect(all_headers.request_headers))
ngx.say(inspect(all_headers.response_headers))
ngx.say(bootstrap_footer)
ngx.exit(ngx.OK)
]]
ngx.say("<div class='content-thisfile'><p><label>Code for this page</label></p>")
ngx.say("<div><pre class='prettyprint'><code class='lang-lua'>"..this_file.."</code></pre></div>")
ngx.say("</div>")
ngx.say(bootstrap_footer)
ngx.exit(ngx.OK)
