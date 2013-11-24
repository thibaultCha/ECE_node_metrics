http    = require 'http'
express = require 'express'
stylus  = require 'stylus'
config  = require '../config'
app     = express()
bcrypt  = require 'bcrypt'	
salt    = bcrypt.genSaltSync 10

metrics = require './metrics'
users   = require './users'

LevelStore = require('./db') "#{__dirname}/../db/sessions"

app.set 'views', "#{__dirname}/../views"
app.set 'view engine', 'jade'
app.use express.bodyParser()
app.use express.methodOverride()
app.use express.cookieParser 'abcd'
app.use express.session
	secret: "123456"
	#store: LevelStore
app.use app.router
app.use stylus.middleware "#{__dirname}/../public"
app.use express.static "#{__dirname}/../public"
app.use express.errorHandler
	showStack: true
	dumpException: true


### REST API ###
metric_get = (req, res) ->
	metrics.get req.params.id, (err, metrics) ->
		return next err if err
		res.json
			id: req.params.id
			metrics: metrics
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
app.post '/users.json', (req, res) ->
	users.save req.body.user, (err, user) ->
		return next err if err
		res.json
			user: user

### WEBSITE ###
app.get '/', (req, res) ->
	console.log req.session
	res.render 'index', { title: "Metrics" }

app.get '/login', (req, res) ->
	res.render 'login', { title: "Login" }

app.post '/login', (req, res) ->
	users.get req.body.email, (err, user) ->
		if user is null
			res.send 404
		else if bcrypt.compareSync(req.body.password, user.password)
			thirtyMinutes = (60*60*1000)/2
			req.session.cookie.expires = new Date(Date.now() + thirtyMinutes)
			req.session.cookie.maxAge = thirtyMinutes
			res.redirect '/'
		else
			res.send 401

app.get '/register', (req, res) ->
	res.render 'register', { title: "Register" }

app.post '/register', (req, res) ->
	user =
		email: req.body.email
		name: req.body.name
		password: req.body.password
	users.save user, (err, user) ->
		return next err if err
		console.log 'user saved'
		console.log user
		res.redirect '/login'

###
app.all '*', (req, res) ->
	res.send 405
###

http.createServer(app).listen config.PORT, ->
  console.log('Express server listening on port ' + config.PORT)
