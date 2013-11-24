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
						return callback new Error "No metrics with id:  #{metric_id}"
			else
				callback new Error "No matching user for email: #{user.email}"

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
					user_metrics = []
					if metrics_ids.length > 0
						for metric, i in metrics_ids
							metrics.get metric, (err, fetched_metrics) ->
								return callback err if err
								user_metrics.push
									id: metric
									metrics: fetched_metrics
								if i == metrics_ids.length
									callback null, user_metrics
					else
						callback null, user_metrics
			else
				callback new Error "No matching user for email: #{user.email}"

	removeMetrics: (user, metric_id, callback) ->
		users.get user.email, (err, fetched_user) ->
			return callback err if err
			if fetched_user isnt null
				
			else
				callback new Error "No matching user for email: #{user.email}"

