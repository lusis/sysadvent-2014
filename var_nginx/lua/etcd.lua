local users_dict = ngx.shared.ng_users_dict
local shared_dict = ngx.shared.ng_shared_dict
local locks = ngx.shared.ng_shared_locks
local lbs = ngx.shared.ng_loadbalancers
local pid = ngx.worker.pid()

local cjson = require 'cjson'
local inspect = require 'inspect'
local lock = require 'resty.lock'
local watch_etcd
local mylock = lock:new("ng_shared_locks",{timeout = 30})
local etcd_url = shared_dict:get("etcd_url")
local watch_params = {etcd_url=etcd_url, path="/v2/keys/lbs/"}

watch_etcd = function(premature, opts)
  if premature then return nil end
  local t = opts or {}
  local etcd_url = t.etcd_url or "http://127.0.0.1:4001"
  local path = opts.path or "/v2/keys/_etcd/"
  local function list()
    local hc = require 'resty.http'.new()
    hc:set_timeout(30000)
    local list_params = "?recursive=true&sorted=true"
    local p = path
    local res, err = hc:request_uri(etcd_url..p..list_params)
    if err then
      ngx.log(ngx.INFO, pid.." initial listing failed: "..err)
      return nil
    else
      if res.status == 404 then ngx.log(ngx.INFO, pid.." directory not found"); return nil end
      ngx.log(ngx.INFO, pid.." got initial listing")
      local nodes = {}
      local ok, j = pcall(cjson.decode, res.body)
      if not ok then ngx.log(ngx.INFO, pid.." couldn't decode json"); return nil end

      local function walk(j, t1) 
        for k,v in pairs(j) do
          if v.dir then walk(v.nodes, t1) end
          if v.key then t1[v.key] = v.value end
        end
        return t1
      end

      return walk(j, nodes)
    end
  end

  local function wait(index)
    local locked, err = mylock:lock("etcd_poll")
    if err then
      -- couldn't get lock, go back into reacquire mode
      return nil
    else
      ngx.log(ngx.INFO, pid.." got lock")
    end
  
    if #lbs:get_keys() == 0 then
      -- possible that we've not yet populated dict
      ngx.log(ngx.INFO, pid, " no existing lbs found. Doing a full refresh")
      initial_list = list()
      if not initial_list then
        ngx.log(ngx.INFO, pid.." unable to build initial list")
      else
        ngx.log(ngx.INFO, pid.." initial backends list: "..inspect(initial_list))
        for k, v in pairs(initial_list) do
          lbs:set(k, v)
        end
      end
    end
    local hc = require 'resty.http'.new()
    hc:set_timeout(30000)
    local p = path
    local watch_params = "?wait=true&recursive=true"
    if index then params = params + "&waitIndex="..index end
    local res, err = hc:request_uri(etcd_url..p..watch_params)
    if err then
      ngx.log(ngx.INFO, pid.. " got an error: "..err)
      local ok, err = mylock:unlock()
      if not ok then
        ngx.log(ngx.INFO, pid.." unable to clear lock")
      else
        ngx.log(ngx.INFO, pid.." lock held for "..locked)
      end
      return nil
    else
      if not res.body then
        ngx.log(ngx.INFO, pid.." no body found: headers: "..inspect(res.headers))
      else
        local j = cjson.decode(res.body)
        ngx.log(ngx.INFO, pid.." got a response on watch")
        if (j.action == "set" and not j.prevNode) then
          ngx.log(ngx.INFO, pid, " adding new backend: ", j.node.key, " [", j.node.value, "]")
          lbs:set(j.node.key, j.node.value)
        elseif (j.action == "set" and j.prevNode) then
          ngx.log(ngx.INFO, pid, " updating backend: ", j.node.key, " [", j.node.value, "]")
          lbs:set(j.node.key, j.node.value)
        elseif (j.action == "delete") then
          ngx.log(ngx.INFO, pid, " deleting backend: ", j.node.key, " [", j.node.value, "]")
          lbs:delete(j.node.key)
        else
          ngx.log(ngx.INFO, pid, " don't know what to do with: ", inspect(j))
        end
        local ok, err = hc:set_keepalive()
      end
    end
    local ok, err = mylock:unlock()
    if not ok then
      ngx.log(ngx.INFO, pid.." unable to clear lock")
    else
      ngx.log(ngx.INFO, pid.." lock held for "..locked)
    end
    return true
  end
  res = wait()
  if res then
    ngx.log(ngx.INFO, pid.." finished polling")
  --else
  --  print(pid.." could not poll")
  end
  watch_etcd(nil, watch_params)
end

if not etcd_url then
  ngx.log(ngx.INFO, "no etcd url passed in. disabling etcd polling")
else
  local ok, err = ngx.timer.at(0, watch_etcd, watch_params)
  if not ok then
    ngx.log(ngx.INFO, pid.." failed to start initial timer")
  else
    ngx.log(ngx.INFO, pid.." initial timer started")
  end
end
