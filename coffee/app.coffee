APP_CONFIG = require './config'
express = require 'express';
util = require 'util'
app = module.exports = express.createServer();
tracker = require './track'

app.configure(->
  app.set 'views', __dirname + '/../views'
  app.set 'view engine', 'jade'
  app.use express.bodyParser()
  app.use express.methodOverride()
  app.use app.router
  app.use express.static __dirname + '/../public'
)

app.configure 'development', ->
  app.use express.errorHandler
      dumpExceptions: true
      showStack: true  

app.configure('production', ->
  app.use express.errorHandler() 
)

app.get '/', (req, res) ->
  res.render 'index',
    title: 'Coffee in Express'

app.get '/post', (req, res) ->
  res.render 'index',
    title: 'Express'

app.post '/test', (req, res) ->
  tracker.find 'records', {},(result) ->
    res.send(result);

app.get '/monitor.do', (req, res) ->
  console.log 'via get'
  app.handleRequest req, res

app.post '/monitor.do', (req, res)->
  console.log 'via post'
  app.handleRequest req, res

app.handleRequest = (req, res)->
  tracker.handleRequest(req)
  res.writeHead(200, {
    'Content-Type': 'text/plain'
  })
  res.end('Message received.\n')

    
app.listen 3000
console.log "Express server listening on port %d", app.address().port 

