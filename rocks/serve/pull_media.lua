-- click reporting and redirection
local utils_redis = require "utils_redis"

local impbidid = ngx.var.impbidid

ngx.print(utils_redis.lookup(impbidid))
utils_redis.log(ngx.time(), "Media Served")
return ngx.exit(ngx.OK)
