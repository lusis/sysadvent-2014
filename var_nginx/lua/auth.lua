local cjson = require 'cjson'
local headers = ngx.req.get_headers()
local users_dict = ngx.shared.ng_users_dict
local inspect = require 'inspect'
local keys = users_dict:get_keys()
local valid_users = {}
for k, v in pairs(keys) do
  valid_users[v] = cjson.decode(users_dict:get(v))
end

local function get_user()
   local header =  headers['Authorization']
   if header == nil or header:find(" ") == nil then
      return
   end
   
   local divider = header:find(' ')
   if header:sub(0, divider-1) ~= 'Basic' then
      return
   end
   
   local auth = ngx.decode_base64(header:sub(divider+1))
   if auth == nil or auth:find(':') == nil then
      return
   end

   divider = auth:find(':')
   local user = auth:sub(0, divider-1)
   local pass = auth:sub(divider+1)
   if not valid_users[user] or valid_users[user].password ~= pass then
      return nil
   end
   
   return user
end

local user = get_user()
if not user then
  ngx.header.content_type = 'text/plain'
  ngx.header.www_authenticate = 'Basic realm="Soopersekrit SysAdvent Section"'
  ngx.status = ngx.HTTP_UNAUTHORIZED
  ngx.say('401 Access Denied')
else
  ngx.say("You got in!")
  ngx.exit(ngx.OK)
end
