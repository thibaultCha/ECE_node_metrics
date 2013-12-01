http       = require 'http'
express    = require 'express'
LevelStore = require('connect-level')(express)
stylus     = require 'stylus'
nib        = require 'nib'
config     = require '../config'
app        = express()
bcrypt     = require 'bcrypt'	
salt       = bcrypt.genSaltSync 10

metrics  = require './metrics'
uMetrics = require './users_metrics'
users    = require './users'

app.set 'views', "#{__dirname}/../views"
app.set 'view engine', 'jade'
app.use stylus.middleware
	src: "#{__dirname}/../public"
	compile: (str, path) ->
		  return stylus(str)
		  .set('filename', path)
		  .set('compress', true)
		  .use(nib())
app.use express.bodyParser()
app.use express.methodOverride()
app.use express.cookieParser 'abcd'
app.use express.session
  store: new LevelStore
    path: 'db/sessions'
  secret:'abcd'
app.use app.router
app.use stylus.middleware "#{__dirname}/../public"
app.use express.static "#{__dirname}/../public"
app.use express.errorHandler
	showStack: true
	dumpException: true

### REST API ###

# Metrics, only used for tests purposes
# /!\ no authentification
metric_get = (req, res, next) ->
	id = parseInt(req.params.id)
	metrics.get id, (err, metrics) ->
		return next err if err
		if metrics.length > 0
			res.json id: id, metrics: metrics
		else
			res.send 404
app.get '/metrics/:id.json', metric_get

app.get '/metrics?metric=:id', metric_get

app.post '/metrics/:id.json', (req, res, next) ->
	metrics.save req.params.id, req.body.metrics, (err) ->
		return next err if err
		metric_get req, res, next

app.delete '/metrics/:id.json', (req, res, next) ->
	metrics.delete req.params.id, (err, success) ->
		return next err if err
		if success
			res.send 200
		else
			res.send 404

# Users
auth = (req, res, next) ->
	if req.session.valid is true
		next()
	else
		res.redirect '/login'

app.post '/users.json', (req, res, next) ->
	users.save req.body.user, (err, user) ->
		return next err if err
		res.json user

app.get '/users/:email.json', (req, res, next) ->
	users.get req.params.email, (err, fetched_user) ->
		return next err if err
		if fetched_user isnt null
			res.json fetched_user
		else
			res.send 404

app.get '/users/:email/:id.json', auth, (req, res, next) ->
	uMetrics.getMetrics req.params.email, (err, metrics_ids) ->
		if req.params.id in metrics_ids
			metric_get req, res, next
		else
			res.send 401

app.delete '/users/:email.json', (req, res, next) ->
	users.delete req.params.email, (err, success) ->
		return next err if err
		if success
			res.send 200
		else
			res.send 404

app.get '/users/:email/metrics.json', (req, res, next) ->
	uMetrics.getMetrics req.params.email, (err, user_metrics) ->
		return next err if err
		res.json user_metrics

app.post '/users/:email/metrics.json', (req, res, next) ->
	uMetrics.addMetrics req.params.email, parseInt(req.body.metrics_id), (err) ->
		return next err if err
		res.send 200

### WEBSITE ###

app.get '/', auth, (req, res) ->
	res.render 'index'
		title: "Metrics"
		user: req.session.user

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
			req.session.user = user
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
		res.redirect '/login'

app.get '/logout', auth, (req, res, next) ->
	req.session.valid = false
	res.redirect '/login'

app.get '/user', auth, (req, res, next) ->
	console.log req.session
	res.render 'user', { user: req.session.user }

###
app.all '*', (req, res) ->
	res.send 405
###

http.createServer(app).listen config.PORT, ->
  console.log('Express server listening on port ' + config.PORT)
