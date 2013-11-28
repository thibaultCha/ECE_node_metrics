db = require('./db') "#{__dirname}/../db/users"
bcrypt  = require 'bcrypt'
salt    = bcrypt.genSaltSync 10
metrics = require('./metrics')

module.exports =
	get: (email, callback) ->
		user = null
		rs = db.createReadStream
		  start:"user:#{email}"
		  stop:"user:#{email}"
		rs.on 'data', (data) ->
			[user_mail, name, password] = data.value.split ':'
			if user_mail == email
				user =
					email: email
					name: name
					password: password
		rs.on 'error', (err) ->
			return callback err if err
		rs.on 'close', ->
			callback null, user

	save: (user, callback) ->
		@get user.email, (err, fetched_user) ->
			return callback err if err
			if fetched_user is null
				ws = db.createWriteStream()
				user.password = if user.password then bcrypt.hashSync(user.password, salt) else ''
				ws.write 
					key: "user:#{user.email}"
					value: user.email+":"+user.name+":"+user.password
				ws.on 'error', (err) ->
					return callback err if err
				ws.on 'close', ->
					callback null, user
				ws.end()
			else
				callback new Error "User with email: #{user.email} already exists"

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
