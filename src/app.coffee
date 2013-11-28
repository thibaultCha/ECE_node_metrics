http       = require 'http'
express    = require 'express'
LevelStore = require('connect-level')(express)
stylus     = require 'stylus'
config     = require '../config'
app        = express()
bcrypt     = require 'bcrypt'	
salt       = bcrypt.genSaltSync 10

metrics = require './metrics'
users   = require './users'

app.set 'views', "#{__dirname}/../views"
app.set 'view engine', 'jade'
app.use express.bodyParser()
app.use express.methodOverride()
app.use express.cookieParser 'abcd'
app.use express.session
	store: new LevelStore()
	secret: 'keyboard cat'
app.use app.router
app.use stylus.middleware "#{__dirname}/../public"
app.use express.static "#{__dirname}/../public"
app.use express.errorHandler
	showStack: true
	dumpException: true


### REST API ###

# Metrics
metric_get = (req, res, next) ->
	id = parseInt(req.params.id)
	metrics.get id, (err, metrics) ->
		return next err if err
		res.json
			id: id
			metrics: metrics
app.get '/metrics/:id.json', metric_get

app.get '/metrics?metric=:id', metric_get

app.post '/metrics/:id.json', (req, res, next) ->
	metrics.save req.params.id, req.body.metrics, (err) ->
		return next err if err
		metric_get req, res, next

app.delete '/metrics/:id.json', (req, res, next) ->
	metrics.delete req.params.id, (err) ->
		return next err if err
		res.send 200

# Users
app.post '/users.json', (req, res, next) ->
	users.save req.body.user, (err, user) ->
		return next err if err
		res.json user

app.get '/users/:email.json', (req, res, next) ->
	users.get req.params.email, (err, fetched_user) ->
		return next err if err
		res.json fetched_user

app.delete '/users/:email.json', (req, res, next) ->
	users.delete req.params.email, (err) ->
		return next err if err
		res.send 200 

### WEBSITE ###

app.get '/', (req, res) ->
	console.log req.session
	if !req.session.valid
		res.redirect '/login'
	else
		res.render 'index', { title: "Metrics" }

app.get '/login', (req, res) ->
	res.render 'login', { title: "Login" }

app.post '/login', (req, res) ->
	users.get req.body.email, (err, user) ->
		if user is null
			res.send 404
		else if bcrypt.compareSync(req.body.password, user.password)
			thirtyMinutes = (60*60*1000)/2
			#thirtyMinutes = (60*1000)/2 # test 30 seconds
			req.session.cookie.expires = new Date(Date.now() + thirtyMinutes)
			req.session.cookie.maxAge = thirtyMinutes
			req.session.valid = true
			res.redirect '/'
		else
			res.send 401

app.get '/register', (req, res) ->
	res.render 'register', { title: "Register" }

app.post '/register', (req, res, next) ->
	user =
		email: req.body.email
		name: req.body.name
		password: req.body.password
	users.save user, (err, saved_user) ->
		return next err if err
		console.log 'user saved'
		console.log saved_user
		res.redirect '/login'

###
app.all '*', (req, res) ->
	res.send 405
###

http.createServer(app).listen config.PORT, ->
  console.log('Express server listening on port ' + config.PORT)
