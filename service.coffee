Kefir = require 'kefir'
Redis = require 'redis'
redis = Redis.createClient()
StreamService = require './stream-service'

findDomainKeys = ->
    Kefir.fromNodeCallback (cb) ->
        redis.keys 'backends:*', cb

findDomainIPs = (domain_key) ->
    Kefir.fromNodeCallback (cb) ->
        redis.smembers domain_key, cb

getRouteData = (domain_key) ->
    domain = domain_key.split('backends:')[1]
    findDomainIPs(domain_key).map (ips) ->
        {domain, ips}

findRoutes = ->
    console.log '[findRoutes]'
    route_keys = findDomainKeys()
    route_keys.flatMap (keys) ->
        Kefir.combine(keys.map(getRouteData))

addRoute = (domain, ip) ->
    console.log '[addRoute]', domain, '->', ip
    Kefir.fromNodeCallback (cb) ->
        redis.sadd 'backends:' + domain, ip, cb

removeRoute = (domain, ip) ->
    console.log '[removeRoute]', domain, '->', ip
    Kefir.fromNodeCallback (cb) ->
        redis.srem 'backends:' + domain, ip, cb

StreamService 'chinook', {
    findRoutes
    addRoute
    removeRoute
}

