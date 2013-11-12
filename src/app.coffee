express = require 'express'
stylus  = require 'stylus'
app     = express()

metrics = require './metrics'

app.use express.bodyParser()
app.use express.methodOverride()
app.use app.router
app.use express.errorHandler
	showStack: true
	dumpException: true

app.get '/metrics/:id.json', (req, res) ->
	metrics.get req.params.id, (err, metrics) ->
		return next err if err
		res.json
			id: req.params.id
			metrics: metrics

app.post '/metrics/:id.json', (req, res) ->
	console.log req.params.id
	metrics.save req.params.id, req.body.metrics, (err) ->
		return next err if err
		res.json
			id: req.params.id
			metrics: req.body.metrics

app.listen 8888, ->
	console.log 'Application listening on 8888'