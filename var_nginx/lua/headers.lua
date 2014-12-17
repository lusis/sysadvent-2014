local cjson = require 'cjson'
local inspect = require 'inspect'
ngx.say(bootstrap_header)
local all_headers = {}
local codelink = [[
<p><a href='#' onclick='getLuaCode("headers.lua", "codesource"); return true;'>Code for this content</a></p>
]]
all_headers.request_headers = ngx.req.get_headers()
all_headers.response_headers = ngx.resp.get_headers()
-- request headers
ngx.say("<div class='content-request'><p><label>Request Headers</label></p>")
ngx.say("<div><pre class='prettyprint'><code class='lang-lua'>"..inspect(all_headers.request_headers).."</code></pre></div>")
ngx.say("</div>")
--response headers
ngx.say("<div class='content-response'><p><label>Response Headers</label></p>")
ngx.say("<div><pre class='prettyprint'><code class='lang-lua'>"..inspect(all_headers.response_headers).."</code></pre></div>")
ngx.say("</div>")
ngx.say(codelink)
ngx.say("<pre class='prettyprint'><code id='codesource' class='lang-lua'></code></pre>")
ngx.say(bootstrap_footer)
ngx.exit(ngx.HTTP_OK)
