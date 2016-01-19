polar = require 'somata-socketio'
polar_auth = require 'polar-auth'
somata = require 'somata'
config = require './config'

client = new somata.Client

findUser = (query, cb) ->
    client.remote 'chinook', 'findUser', query, cb

getUser = (user_id, cb) ->
    client.remote 'chinook', 'getUser', user_id, cb

auth = polar_auth config.auth, {findUser, getUser, id_key: 'id'}
config.app.middleware = [auth.session_middleware]
app = polar config.app

app.get '/', auth.requireLogin, (req, res) -> res.render 'base'
app.get '/login', auth.showLogin
app.get '/logout', auth.doLogout
app.post '/login.json', auth.doLogin, (req, res) ->
    console.log 'announce it'
    res.json
        success: true
        user: res.locals.user

app.start()
