db = require('./db') "#{__dirname}/../db/users"
bcrypt  = require 'bcrypt'
salt    = bcrypt.genSaltSync 10
metrics = require('./metrics')

module.exports =
	get: (email, callback) ->
		user = null
		rs = db.createReadStream
		  start:"user:#{email}:"
		  stop:"user:#{email}:"
		rs.on 'data', (data) ->
			[name, password] = data.value.split ':'
			user =
				email: email
				name: name
				password: password
		rs.on 'error', (err) ->
			return callback err if err
		rs.on 'close', ->
			callback null, user

	save: (user, callback) ->
		ws = db.createWriteStream()
		ws.write 
			key: "user:#{user.email}:"
			value: user.name+":"+ if user.password then bcrypt.hashSync(user.password, salt) else ''
		ws.on 'error', (err) ->
			return callback err if err
		ws.on 'close', ->
			callback null, user
		ws.end()

	delete: (email, callback) ->
		exists = false
		rs = db.createReadStream
			start:"user:#{email}"
			stop:"user:#{email}"
		rs.on 'data', (data) ->
			exists = true
			db.del data.key, (err) ->
				return callback err if err
		rs.on 'error', (err) ->
			return callback err if err
		rs.on 'close', ->
			callback(if exists then null else new Error "No user for email #{email}")
