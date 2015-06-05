somata = require 'somata'
Kefir = require 'kefir'

asCallback = (streamf) -> (args...) ->
    [cb] = args.splice(args.length-1)
    streamf(args...).onValue (value) -> cb null, value

asCallbacks = (_o) ->
    o = {}
    for k, f of _o
        o[k] = asCallback f
    o

StreamService = (n, fs) ->
    new somata.Service n, asCallbacks fs

module.exports = StreamService
