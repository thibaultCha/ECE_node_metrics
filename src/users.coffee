db = require('./db') "#{__dirname}/../db/users"

module.exports =
	get: (email, options, callback) ->
		callback = options if arguments.length is 2
		user = null
		rs = db.createReadStream
		  start:"user:#{email}"
		  stop:"user:#{email}"
		rs.on 'data', (data) ->
			[_, email] = data.key.split ':'
			user = 
				email: email, 
				name: data.value
		rs.on 'error', (err) ->
			return callback err if err
		rs.on 'close', ->
			callback null, user

	save: (user, callback) ->
		ws = db.createWriteStream()
		ws.write key: "user:#{user.email}", value: user.name
		ws.on 'error', (err) ->
			return callback err if err
		ws.on 'close', ->
			callback()
		ws.end()

	delete: (email, callback) ->
		rs = db.createReadStream
			start:"user:#{email}"
			stop:"user:#{email}"
		rs.on 'data', (data) ->
			db.del data.key, (err) ->
				return callback err if err
		rs.on 'error', (err) ->
			return callback err if err
		rs.on 'close', ->
			callback()		