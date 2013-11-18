http    = require 'http'
express = require 'express'
jade    = require 'jade'
stylus  = require 'stylus'
config  = require '../config'
app     = express()

metrics = require './metrics'

app.set 'views', "#{__dirname}/../views"
app.set 'view engine', 'jade'
app.use express.bodyParser()
app.use express.methodOverride()
app.use express.cookieParser 'abcd'
app.use express.session()
app.use app.router
app.use stylus.middleware "#{__dirname}/../public"
app.use express.static "#{__dirname}/../public"
app.use express.errorHandler
	showStack: true
	dumpException: true

app.get '/', (req, res) ->
	res.render 'layout'

app.get '/metrics/:id.json', (req, res) ->
	metrics.get req.params.id, (err, metrics) ->
		return next err if err
		res.json
			id: req.params.id
			metrics: metrics

app.post '/metrics/:id.json', (req, res) ->
	metrics.save req.params.id, req.body.metrics, (err) ->
		return next err if err
		metrics.get req.params.id, (err, metrics) ->
			return next err if err
			res.json
				id: req.params.id
				metrics: metrics

app.delete '/metrics/:id.json', (req, res) ->
	metrics.delete req.params.id, (err) ->
		return next err if err
		res.send 200

app.all '*', (req, res) ->
	res.send 405

http.createServer(app).listen config.PORT, ->
  console.log('Express server listening on port ' + config.PORT)