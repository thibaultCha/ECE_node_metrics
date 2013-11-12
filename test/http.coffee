{exec}  = require 'child_process'
should  = require 'should'
request = require 'request'
metrics = null

describe 'REST API', ->

	before (next) ->
		exec "rm -rf #{__dirname}/../db/test && mkdir #{__dirname}/../db/test", (err, stdout) ->
			throw err if err
			metrics = require '../lib/metrics'
			
			met = [
				timestamp:(new Date '2013-11-04 14:00 UTC').getTime(), value:1
			,
				timestamp:(new Date '2013-11-04 14:10 UTC').getTime(), value:2
			]
			
			metrics.save 1, met, (err) ->
				throw err if err
				next()

	it 'should get a metric', (next) ->
		request.get 'http://localhost:8888/metrics/1.json', (err, res, body) ->
			return next err if err or res.statusCode isnt 200
			console.log body
			metrics = JSON.parse(body).metrics
			metrics.length.should.equal 2
			next()

	it 'should post a metric', (next) ->
		met = [
			timestamp:(new Date '2013-11-04 14:00 UTC').getTime(), value:3
		,
			timestamp:(new Date '2013-11-04 14:10 UTC').getTime(), value:4 
		]
		request.post 'http://localhost:8888/metrics/1.json', { form: { metrics: met } }, (err, res, body) ->
			metrics = JSON.parse(body).metrics
			console.log body
			metrics.length.should.equal 2
			metrics[0].value.should.equal '3'
			next()

	after (next) ->
		exec "rm -rf #{__dirname}/../db/test && mkdir #{__dirname}/../db/test", (err, stdout) ->
			throw err if err
			next()