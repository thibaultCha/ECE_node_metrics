db = require('./db') "#{__dirname}/../db/users"
metrics = require('./metrics')

module.exports =
	get: (email, callback) ->
		console.log 'asked email: ' + email
		user = null
		rs = db.createReadStream
		  start:"user:#{email}"
		  stop:"user:#{email}"
		rs.on 'data', (data) ->
			console.log 'DATA'
			console.log data
			[name, password] = data.value.split ':'
			user =
				email: email
				name: name
				password: password
		rs.on 'error', (err) ->
			return callback err if err
		rs.on 'close', ->
			console.log user
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

	addMetrics: (user, metric_id, callback) ->
		@get user.email, (err, fetched_user) ->
			return callback err if err
			if fetched_user isnt null
				metrics.get metric_id, (err, metrics) ->
					return callback err if err
					if metrics.length > 0
						ws = db.createWriteStream()
						ws.write
							key:"user_metric:#{user.email}:#{metric_id}"
							value: ' '
						ws.end()
						ws.on 'error', (err) ->
							return callback err if err
						ws.on 'close', ->
							callback null
					else
						return callback new Error 'No metrics with id: ' + metric_id
			else
				callback new Error 'No matching user for email: ' + user.email

	getMetrics: (user, callback) ->
		@get user.email, (err, fetched_user) ->
			return callback err if err
			if fetched_user isnt null
				callback null
			else
				callback new Error 'No matching user for email: ' + user.email

###
	addMetrics: (user, metric_id, callback) ->
		@get user.email, (err, user) ->
			return callback err if err
			if user isnt null
				metrics.get metric_id, (err, metrics) ->
					return callback err if err
					if metrics.length > 0
						ws = db.createWriteStream()
						ws.write
							key:"user_metric:#{user.email}:#{metric_id}"
							value: ' '
						ws.end()
						ws.on 'error', (err) ->
							return callback err if err
						ws.on 'close', ->
							callback null
					else
						callback new Error 'No metrics for id: ' + metric_id
			else
				callback new Error 'No user matching: ' + user.email

	getMetrics: (user, callback) ->
		@get user.email, (err, user) ->
			return callback err if err
			if user isnt null
				mets = []
				rs = db.createReadStream
					start:"user_metric:#{user.email}:"
					stop:"user_metric:#{user.email}:"
				rs.on 'data', (data) ->
					[_, _, metric_id] = data.key.split ':'
					metrics.get metric_id, (err, metrics_result) ->
						return callback err if err
						mets = metrics_result
						callback null, metrics_result
				rs.on 'error', (err) ->
					return callback err if err
			else
				callback new Error 'No user matching: ' + user.email

	removeMetrics: (email, metric_id, callback) ->
###