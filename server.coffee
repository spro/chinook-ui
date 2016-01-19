polar = require 'somata-socketio'
polar_auth = require 'polar-auth'
somata = require 'somata'
config = require './config'

client = new somata.Client

config.getUser = (query, cb) ->
    client.remote 'chinook', 'getUser', query, cb

config.checkUser = (query, cb) ->
    client.remote 'chinook', 'checkUser', query, cb

auth = polar_auth(config)
app_config = config.app
app_config.middleware = [auth.session_middleware]
app = polar app_config

app.get '/', auth.requireLogin, (req, res) -> res.render 'base'
app.get '/login', auth.showLogin
app.get '/logout', auth.doLogout
app.post '/login.json', auth.doLogin, (req, res) ->
    console.log 'announce it'
    res.json
        success: true
        user: res.locals.user

app.start()
