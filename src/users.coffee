db = require('./db') "#{__dirname}/../db/users"
metrics = require('./metrics')

module.exports =
	get: (email, callback) ->
		user = null
		rs = db.createReadStream
		  start:"user:#{email}"
		  stop:"user:#{email}"
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
			key: "user:#{user.email}"
			value: user.name+":"+user.password
		ws.on 'error', (err) ->
			return callback err if err
		ws.on 'close', ->
			console.log 'SAVED: ' + user.email
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
