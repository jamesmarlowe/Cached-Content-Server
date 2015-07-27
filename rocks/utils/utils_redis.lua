local redis = require "resty.redis"
local log_counter = ngx.shared.log_counter

-- define a module (lua table)
local utils = {}

function utils.lookup(key)
    local red = redis:new()

    red:set_timeout(1000) -- 1 sec

    local ok, retries = nil, 0
    while ((not ok) and retries < 3) do
        retries = retries + 1
        local ok, err = red:connect("127.0.0.1", 6379)
        if not ok then
            ngx.log(ngx.CRIT, err)
            utils.log(ngx.time(), "Cached Media Connect Fail")
            break
        end
    end

    local multi, err = red:multi()
    local ok, err = multi and red:get(key)
    local ok, err = multi and ok and red:del(key)
    local res, err = multi and ok and red:exec()
    local ok, err = red:set_keepalive()
    local ok, err = red:close()
    return (type(res[1])=="string") and res[1]
end

function utils.log(key, field, incrby)
    local val = log_counter:incr(key..field,incrby or 1)
    if not val then log_counter:add(key..field, incrby or 1, 600) end
    local red = redis:new()

    red:set_timeout(1000) -- 1 sec

    --local ok, err = red:connect("unix:/var/run/redis/redis.sock")
    local ok, err = red:connect("localhost", 6379)
    if not ok then
        return
    end

    if incrby then
        local res, err = red:hincrbyfloat(key, field, incrby or 1)
    else
        local res, err = red:hincrby(key, field, 1)
    end
    local res, err = red:expire(key, 600)
    local ok, err = red:set_keepalive()
    return res
end

return utils
