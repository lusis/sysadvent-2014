local content = [[
  <div class="content">
  <h1>ngx.location.capture</h1>

  <p>Within each worker, care must be taken when using lua to perform only non-blocking operations to prevent blocking the worker's event loop so that it can process other connections.</p>
  <p>Since we have access to lua, we could conceivably use a socket library to initiate network connections (such as talking to a backend service).</p>
  <p>Doing this with standard socket calls would block the worker.
  The basic way around this is to use the <i>ngx.location.capture</i> function in conjunction with an <i>internal</i> location in your nginx config:</p>
  <pre>
  location /call_backend {
    internal;
    resolver 8.8.8.8;
    proxy_pass "http://mybackend:8080/getdata";
  }
  </pre>

  An internal location is not exposed to outside network calls. It only exists as a location to the worker.
  Calls made using location capture are non-blocking so that the worker can service other requests coming in.
  <p>The following form will use this capture mechanism to query the github public api for the provided username. This will be non-blocking and results will be displayed in JSON format to your browser.</p>
]]
-- if we don't have any params, we display a form
local form = [[<hr/><p>Enter a username to find on github:</p> <form action="/github"><input type="text" name="username"><br/><input type="submit"></form>]]

ngx.say(bootstrap_header)
ngx.say(content)
ngx.say(form)

local username = ngx.var.arg_username

if username then
  -- we call github because we've been asked to
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
    ngx.say("<div class='alert alert-danger'>Something went goofy talking to github</div>")
  else
    ngx.say("<div class='github-response'><pre class='prettyprint'><code>"..res.body.."</code></pre></div>")
  end
end

ngx.say("</div>")
local codelink = [[
<p><a href='#' onclick='getLuaCode("github.lua", "codesource"); return true;'>Code for this content</a></p>
]]
ngx.say(codelink)
ngx.say("<pre class='prettyprint'><code id='codesource' class='lang-lua'></code></pre>")
ngx.say(bootstrap_footer)
ngx.exit(ngx.OK)
