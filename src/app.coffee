http    = require 'http'
express = require 'express'
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

met = [
			timestamp:(new Date '2013-11-04 14:00 UTC').getTime(), value:1234
		,
			timestamp:(new Date '2013-11-05 14:10 UTC').getTime(), value:5678
		,
			timestamp:(new Date '2013-12-04 14:11 UTC').getTime(), value:9101
		,
			timestamp:(new Date '2013-12-24 14:11 UTC').getTime(), value:56768
		,
			timestamp:(new Date '2014-01-01 14:11 UTC').getTime(), value:42768
		,
			timestamp:(new Date '2014-01-02 14:11 UTC').getTime(), value:4768
		,
			timestamp:(new Date '2014-01-07 14:11 UTC').getTime(), value:53768
		]

metrics.save 1, met, (err) ->
	throw err if err




metric_get = (req, res) ->
	metrics.get req.params.id, (err, metrics) ->
		return next err if err
		res.json
			id: req.params.id
			metrics: metrics

app.get '/', (req, res) ->
	res.render 'index'

app.get '/metrics/:id.json', metric_get
app.get '/metrics?metric=:id', metric_get

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

#app.all '*', (req, res) ->
#	res.send 405

http.createServer(app).listen config.PORT, ->
  console.log('Express server listening on port ' + config.PORT)