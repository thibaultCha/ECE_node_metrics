db = require('./db') "#{__dirname}/../db/users-metrics"
metrics = require('./metrics')
users   = require('./users')

module.exports =
	addMetrics: (email, metric_id, callback) ->
		users.get email, (err, fetched_user) ->
			return callback err if err
			if fetched_user isnt null
				metrics.get metric_id, (err, metrics) ->
					return callback err if err
					if metrics.length > 0
						ws = db.createWriteStream()
						ws.write
							key:"user_metric:#{email}:#{metric_id}"
							value: ' '
						ws.end()
						ws.on 'error', (err) ->
							return callback err if err
						ws.on 'close', ->
							callback null
					else
						return callback new Error "No metrics with id: #{metric_id}"
			else
				callback new Error "No matching user for email: #{email}"

	getMetrics: (email, callback) ->
		users.get email, (err, fetched_user) ->
			return callback err if err
			if fetched_user isnt null
				metrics_ids = []
				rs = db.createReadStream
				  start:"user_metric:#{email}:"
				  stop:"user_metric:#{email}:"
				rs.on 'data', (data) ->
					[_, user_mail, met_id] = data.key.split ':'
					if user_mail is email
						metrics_ids.push parseInt(met_id)
				rs.on 'error', (err) ->
					return callback err if err
				rs.on 'close', ->
					user_metrics = []
					counter = 0
					if metrics_ids.length > 0
						for metric in metrics_ids
							metrics.get metric, (err, fetched_metrics) ->
								return callback err if err
								user_metrics.push
									id: fetched_metrics[0].id
									metrics: fetched_metrics
								counter++
								if counter is metrics_ids.length
									callback null, user_metrics
					else
						callback null, user_metrics
			else
				callback new Error "No matching user for email: #{email}"

	removeMetrics: (email, metric_id, callback) ->
		@getMetrics email, (err, metrics) ->
			return callback err if err
			if metrics.length > 0
				rs = db.createReadStream
					start:"user_metric:#{email}:"
					stop:"user_metric:#{email}:"
				rs.on 'data', (data) ->
					db.del data.key, (err) ->
						return callback err if err
				rs.on 'error', (err) ->
					return callback err if err
				rs.on 'close', ->
					callback()
			else
				callback new Error "User #{email} does not have metrics: #{metric_id}"
