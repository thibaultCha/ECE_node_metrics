db = require('./db') "#{__dirname}/../db/metrics"

module.exports =
	get: (id, options, callback) ->
		callback = options if arguments.length is 2
		metrics = []
		rs = db.createReadStream
		  start:"metric:#{id}:"
		  stop:"metric:#{id}:"
		rs.on 'data', (data) ->
			[_, met_id, timestamp] = data.key.split ':'
			# start: stop: is WTF. Dirty if to double check.
			# console.log met_id + ' ' + id
			if parseInt(met_id) is id
				metrics.push
					id: parseInt(id),
					timestamp: parseInt(timestamp, 10),
					value: parseInt(data.value)
		rs.on 'error', (err) ->
			return callback err if err
		rs.on 'close', ->
			callback null, metrics

	save: (id, metrics, callback) ->
		ws = db.createWriteStream()
		for metric in metrics
			{timestamp, value} = metric
			ws.write key:"metric:#{id}:#{timestamp}", value: value
		ws.on 'error', (err) ->
			return callback err if err
		ws.on 'close', ->
			callback()
		ws.end()

	delete: (id, callback) ->
		rs = db.createReadStream
			start:"metric:#{id}:"
			stop:"metric:#{id}:"
		rs.on 'data', (data) ->
			db.del data.key, (err) ->
				return callback err if err
		rs.on 'error', (err) ->
			return callback err if err
		rs.on 'close', ->
			callback()
