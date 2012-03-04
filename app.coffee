express = require 'express'

Twitter = require 'twitter'
config = require './config/kijitora'

app = express.createServer()
io  = require('socket.io').listen(app)

app.configure ->
  app.use express.static(__dirname + '/public')

app.listen config.application.port

app.get '/', (req, res) ->
  res.sendfile __dirname + '/public/index.html'

io.sockets.on 'connection', (socket) ->
  console.log("sockets.on connection")
  twitter = new Twitter(config.twitter)
  twitter.stream "user", {}, (stream) ->
    console.log("setting up user streams")
    stream.on "data", (data) ->
      console.log("received: #{data}")
      socket.emit "stream", data
    stream.on "error", (data) ->
      console.log("ERROR: #{data}")
      stream.destroy()
    socket.on "disconnect", ->
      console.log("socket disconnected")
      stream.destroy()