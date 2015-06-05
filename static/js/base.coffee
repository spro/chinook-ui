_ = require 'underscore'
React = require 'react/addons'
Kefir = require 'kefir'
somata = require './somata-socketio'

cx = React.addons.classSet

merge = (o1, o2) -> _.extend {}, o1, o2

bools = (o) ->
    b = {}
    for k, v of o
        console.log 'k=',k,'v=',v
        if _.isBoolean v
            b[k] = v
    return b

default_routes = [
    {domain: 'chinook.dev', ips: ['127.0.0.1:2889']}
    {domain: 'debatable.staging', ips: ['128.0.0.1:5952', '128.0.0.1:4222']}
    {domain: 'maia.dev', ips: ['192.168.42.115:10101']}
    {domain: 'gofish.dev', ips: ['128.0.0.1:5952']}
    {domain: 'nexus.dev', ips: ['192.168.42.115:4510']}
]

doOp = (v) ->
    Kefir.stream (emitter) ->
        emitter.emit v

# Helper classes
# -----------------------------------------------------------------------------

Icon = React.createClass
    render: ->
        <a className={"icon #{@props.kind}"} onClick=@props.onClick>
            <img src={"/img/icons/#{@props.kind}.png"} />
        </a>

HasInput =
    setTarget: (key) -> (e) =>
        o = {}; o[key] = e.target.value; @setState o

    onKeyDown: (e) ->
        console.log '[onKeyDown]', e.keyCode
        if e.keyCode == 13
            @onEnter?()

    renderInput: (key, value, placeholder) ->
        placeholder ||= key
        <input ref=key className=key value=value placeholder=placeholder onChange=@setTarget(key) onKeyDown=@onKeyDown />

StateHelpers =
    resetState: ->
        @setState @getInitialState()

# Dispatcher
# -----------------------------------------------------------------------------
# TODO: Break into Store + Dispatcher

AppDispatcher =
    mode: 'search' # search / browse
    routes: default_routes

    updates: Kefir.pool()

    get: (k, cb) ->
        cb null, AppDispatcher[k]

    getStream: (k) ->
        Kefir.fromNodeCallback (cb) ->
            AppDispatcher.get k, cb

    addRoute: (r) ->
        AppDispatcher.routes.push r
        AppDispatcher.updates.plug(Kefir.constant(true))

    removeRoute: (route) ->
        AppDispatcher.routes = AppDispatcher.routes.filter (r) -> r.domain != route.domain

    addIP: (domain, ip) ->
        route = AppDispatcher.routes.filter((r) -> r.domain == domain)[0]
        if route
            route.ips.push ip
        else
            route = {domain, ips: [ip]}
            AppDispatcher.routes.push route
        AppDispatcher.updates.plug(Kefir.constant(true))

    removeIP: (domain, ip) ->
        route = AppDispatcher.routes.filter((r) -> r.domain == domain)[0]
        route.ips = route.ips.filter (i) -> i != ip
        if route.ips.length == 0
            AppDispatcher.removeRoute(route)
        AppDispatcher.updates.plug(Kefir.constant(true))

# Components
# -----------------------------------------------------------------------------

Route = React.createClass
    getInitialState: ->
        adding: false

    toggleAdd: ->
        @setState adding: !@state.adding

    removeIP: (ip) -> =>
        AppDispatcher.removeIP(@props.route.domain, ip)

    render: ->
        <div className='route'>
            <span className='domain'>{@props.route.domain}</span>
            <div className='actions'>
                <Icon kind='add' onClick={@toggleAdd}/>
            </div>
            <div className='ips'>
                {@props.route.ips.map @renderIP}
                {if @state.adding then <NewIP domain=@props.route.domain  />}
            </div>
        </div>
        
    renderIP: (ip) ->
        <div className='ip' key=ip>
            {ip}
            <div className='actions'>
                <Icon kind='remove' onClick={@removeIP(ip)}/>
            </div>
        </div>

NewRoute = React.createClass
    mixins: [HasInput, StateHelpers]

    getInitialState: ->
        domain: ''
        ip: ''

    onEnter: ->
        AppDispatcher.addIP @state.domain, @state.ip
        @resetState()
        @focusDomain()

    focusDomain: ->
        @refs.domain.getDOMNode().focus()

    render: ->
        <div className='new route'>
            {@renderInput('domain', @state.domain)}
            <div className='ips'>
                {@renderInput('ip', @state.ip, 'ip:port')}
            </div>
        </div>

NewIP = React.createClass
    mixins: [HasInput, StateHelpers]

    getInitialState: ->
        ip: ''

    componentDidMount: ->
        @focusIP()

    onEnter: (input) ->
        AppDispatcher.addIP @props.domain, @state.ip
        @resetState()
        @focusIP()

    focusIP: ->
        @refs.ip.getDOMNode().focus()

    render: ->
        @renderInput 'ip', @state.ip, 'ip:port'

Card = React.createClass
    getInitialState: ->
        routes: AppDispatcher.routes

    componentDidMount: ->
        AppDispatcher.updates.onValue =>
            @setState @getInitialState()

    render: ->
        <div className='card'>
            {@state.routes.map (r) -> <Route route={r} key={r.domain} />}
            <NewRoute />
        </div>

App = React.createClass
    render: ->
        <div>
            <img id='logo' src='/img/chinook.png' />
            <Card />
        </div>

# Going
# -----------------------------------------------------------------------------

window.AppDispatcher = AppDispatcher

React.render <App />, document.getElementById 'app'

