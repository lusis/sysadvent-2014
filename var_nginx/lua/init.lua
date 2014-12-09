local users_dict = ngx.shared.ng_users_dict
local shared_dict = ngx.shared.ng_shared_dict
local startup_time = ngx.utctime()
local json_blob = [[{"username":"sysadvent", "password":"supersecret"}]]
shared_dict:set("startup_time", startup_time)
users_dict:set("sysadvent", json_blob)
shared_dict:set("slack_token", os.getenv("SLACK_API_TOKEN"))
