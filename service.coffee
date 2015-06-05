Kefir = require 'kefir'
Redis = require 'redis'
redis = Redis.createClient()
StreamService = require './stream-service'

getDomainKeys = ->
    Kefir.fromNodeCallback (cb) ->
        redis.keys 'backends:*', cb

getDomainIPs = (domain_key) ->
    Kefir.fromNodeCallback (cb) ->
        redis.smembers domain_key, cb

getRouteData = (domain_key) ->
    domain = domain_key.split('backends:')[1]
    getDomainIPs(domain_key).map (ips) ->
        {domain, ips}

getRoutes = ->
    console.log '[getRoutes]'
    route_keys = getDomainKeys()
    route_keys.flatMap (keys) ->
        Kefir.combine(keys.map(getRouteData))

addRoute = (domain, ip) ->
    route = {domain, ip}
    console.log '[addRoute]', route
    Kefir.fromNodeCallback (cb) ->
        redis.sadd 'backends:' + domain, ip, cb

StreamService 'chinook', {
    getRoutes
    addRoute
}

