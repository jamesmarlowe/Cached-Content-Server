local redis = require "resty.redis"
local log_counter = ngx.shared.log_counter

-- define a module (lua table)
local utils = {}

function utils.lookup(key)
    local red = redis:new()

    red:set_timeout(1000) -- 1 sec

    local ok, err = red:connect("cached-media.lumate.org", 6379)
    if not ok then
        ngx.log(ngx.CRIT, err)
        utils.log(ngx.time(), "Cached Media Connect Fail")
        return nil, true
    end

    local res, err = red:get(key)
    local ok, err = red:set_keepalive()
    local ok, err = red:close()
    return res
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
