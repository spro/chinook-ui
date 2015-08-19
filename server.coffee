polar = require 'somata-socketio'
somata = require 'somata'

client = new somata.Client

app = polar port: 2889

app.get '/', (req, res) -> res.render 'base'

app.start()
