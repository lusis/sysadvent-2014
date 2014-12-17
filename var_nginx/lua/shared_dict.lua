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
local intro = [[
<h1>Shared dictionaries</h1>
<p>In nginx, each worker runs in its own context. Workers cannot share data between each other</p>
<p>Nginx's lua support adds a concept of a <i>shared dictionary</i>. This is implemented using shared memory and operates like a bit of a key/value store with operations such as <i>get</i>,<i>set</i> and <i>delete</i></p>
]]

local keys = shared_dict:get_keys()
ngx.say(bootstrap_header)
ngx.say("<div id='content'>")
ngx.say(intro)
local keys = shared_dict:get_keys()
local content = ''
if #keys < 1 then
  ngx.say("<h3>We found no keys in the shared dictionary</h3>")
else
  ngx.say("<p>The following keys and values were set in the nginx shared lua dictionary.</p><p>These keys do not persist through hard bounces but do persist through reloads</p>")
  ngx.say("<table id='shared_dict' class='display' cellspacing=0 width='100%'>")
  ngx.say("<thead><tr><th>key</th><th>value</th><th>action</th></tr></thead>")
  for k, v in pairs(keys) do
    ngx.say("<tr>")
    ngx.say("<td>",v, "</td>")
    ngx.say("<td>",shared_dict:get(v),"</td>")
    ngx.say("<td><a href=/shared_dict?sddelete="..v..">Delete this entry</a></td>")
    ngx.say("</tr>")
  end
  ngx.say("</table>")
end
local form = [[
  <hr/>
  <div class='container'>
  <h3>Add some data to the shared dictionary:</h3>
  <form action="/shared_dict">
  <p><label>key</label><input type="text" name="sdkey">
  <label>value</label><input type="text" name="sdvalue"></p>
  <p><input type="submit"></p>
  </form>
  </div>
]]
ngx.say(form)
ngx.say("</div>")
local codelink = [[
<p><a href='#' onclick='getLuaCode("shared_dict.lua", "codesource"); return true;'>Code for this content</a></p>
]]
ngx.say(codelink)
ngx.say("<pre class='prettyprint'><code id='codesource' class='lang-lua'></code></pre>")
ngx.say(bootstrap_footer)
ngx.exit(ngx.HTTP_OK)
