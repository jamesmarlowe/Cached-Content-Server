-- click reporting and redirection
local utils_redis = require "utils_redis"

local impbidid = ngx.var.impbidid

local media = utils_redis.lookup(impbidid)
if media then
    ngx.print(media)
    utils_redis.log(ngx.time(), "Media Served")
    return ngx.exit(ngx.OK)
else
    utils_redis.log(ngx.time(), "Media Serve Failed")
    return ngx.exit(204)
end
