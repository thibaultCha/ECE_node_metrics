db = require('./db') "#{__dirname}/../db/users-metrics"
metrics = require('./metrics')
users   = require('./users')

module.exports =
	addMetrics: (user, metric_id, callback) ->
		users.get user.email, (err, fetched_user) ->
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
		users.get user.email, (err, fetched_user) ->
			return callback err if err
			if fetched_user isnt null
				metrics_ids = []
				rs = db.createReadStream
				  start:"user_metric:#{user.email}:"
				  stop:"user_metric:#{user.email}:"
				rs.on 'data', (data) ->
					[_, _, met_id] = data.key.split ':'
					metrics_ids.push parseInt(met_id)
				rs.on 'error', (err) ->
					return callback err if err
				rs.on 'close', ->
					callback null, metrics_ids
			else
				callback new Error 'No matching user for email: ' + user.email