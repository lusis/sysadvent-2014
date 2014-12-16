local content = [[
<p>While the <i>content_by_lua</i> is good for simple cases, it falls apart quickly due to the required amount of escaping for real content.</p>
<p>Moving the content out into an external lua file is much easier and starts to open the door for greater flexibility. This is where <i>content_by_lua_file</i> comes in:
<pre>
location /foo {
  content_by_lua_file '/var/nginx/lua/somefile.lua';
}
</pre>
From this point on, all content will come from a <i>content_by_lua_file</i> directive, static html or templates.
]]

local codelink = [[
<p><a href='#' onclick='getLuaCode("luafile_content.lua", "codesource"); return true;'>Code for this content</a></p>
]]

ngx.say(bootstrap_header)
ngx.say("<div class='content'>")
ngx.say("<p>This content comes from:")
ngx.say("<pre>var_nginx/lua/luafile_content.lua</pre>")
ngx.say("</p>")
ngx.say(content)
ngx.say(codelink)
ngx.say("<pre class='prettyprint'><code id='codesource' class='lang-lua'></code></pre>")
ngx.say(bootstrap_footer)
ngx.exit(ngx.HTTP_OK)
