local cjson = require 'cjson'
ngx.header.content_type = "application/json"
local all_headers = {}
all_headers.request_headers = ngx.req.get_headers()
all_headers.response_headers = ngx.resp.get_headers()
ngx.say(cjson.encode(all_headers))
ngx.exit(ngx.OK)
