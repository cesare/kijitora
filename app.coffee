express = require 'express'
everyauth = require 'everyauth'
Twitter = require 'twitter'
config = require './config/kijitora'
parseCookie = (require 'connect').utils.parseCookie

app = express.createServer()
io  = require('socket.io').listen(app)

everyauth.twitter
  .consumerKey(config.twitter.consumer_key)
  .consumerSecret(config.twitter.consumer_secret)
  .findOrCreateUser (session, accessToken, accessTokenSecret, twitterUserMetadata) ->
    session.authorized =
      token: accessToken
      secret: accessTokenSecret
      user: twitterUserMetadata
    twitterUserMetadata
  .entryPath('/auth/twitter')
  .redirectPath '/'

sessionStore = new express.session.MemoryStore()

app.configure ->
  app.use(express.static(__dirname + '/public'))
  app.set('views', __dirname + '/app/views')
  app.set('view options', { layout: true })
  app.set('view engine', 'ejs')
  app.use(express.bodyParser())
  app.use(express.cookieParser())
  app.use(express.session({ secret: 'secret', store: sessionStore }))
  app.use(express.methodOverride())
  app.use(everyauth.middleware())
  app.use(app.router)

everyauth.helpExpress(app)
app.listen config.application.port

findCurrentUser = (request, response, next) ->
  user = request.session?.authorized?.user
  if user
    next()
  else
    response.redirect "/auth/twitter"

app.get '/', findCurrentUser, (req, res) ->
  res.render("index")


io.configure ->
  io.set "authorization", (handshakeData, callback) ->
    cookie = handshakeData.headers.cookie
    if cookie
      sessionId = parseCookie(cookie)["connect.sid"]
      sessionStore.get sessionId, (err, session) ->
        if err
          callback(err.message, false)
        else
          handshakeData.session = session
          callback(null, true)
    else
      callback("Authentication failed", false)

io.sockets.on 'connection', (socket) ->
  session = socket.handshake.session
  params =
    consumer_key: config.twitter.consumer_key
    consumer_secret: config.twitter.consumer_secret
    access_token_key: session.authorized.token
    access_token_secret: session.authorized.secret
  twitter = new Twitter(params)
  twitter.stream "user", {}, (stream) ->
    stream.on "data", (data) ->
      console.log("received: #{data}")
      socket.emit "stream", data
    stream.on "error", (data) ->
      console.log("ERROR: #{data}")
      stream.destroy()
    socket.on "disconnect", ->
      console.log("socket disconnected")
      stream.destroy()