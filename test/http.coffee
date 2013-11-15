{exec}  = require 'child_process'
should  = require 'should'
request = require 'request'
metrics = null

describe 'REST API', ->

	it 'should post and get a metric', (next) ->

		met = [
			timestamp:(new Date '2013-11-04 14:00 UTC').getTime(), value:3
		,
			timestamp:(new Date '2013-11-04 14:10 UTC').getTime(), value:4 
		]

		request.post 'http://localhost:8888/metrics/2.json', { form: { metrics: met } }, (err, res, body) ->
			return next err if err or res.statusCode isnt 200
			metrics = JSON.parse(body).metrics
			metrics.length.should.equal 2
			[m1, m2] = metrics
			m1.id.should.equal 2
			m2.id.should.equal 2
			m1.value.should.equal 3
			m2.value.should.equal 4
			
			request.get 'http://localhost:8888/metrics/2.json', (err, res, body) ->
				return next err if err or res.statusCode isnt 200
				metrics = JSON.parse(body).metrics
				metrics.length.should.equal 2
				[m1, m2] = metrics
				m1.id.should.equal 2
				m2.id.should.equal 2
				m1.value.should.equal 3
				m2.value.should.equal 4

				next()

	it 'should delete a metric', (next) ->
		met = [
			timestamp:(new Date '2013-11-04 14:00 UTC').getTime(), value:5
		,
			timestamp:(new Date '2013-11-04 14:10 UTC').getTime(), value:6 
		]

		request.post 'http://localhost:8888/metrics/3.json', { form: { metrics: met } }, (err, res, body) ->
			return next err if err or res.statusCode isnt 200
			
			request.del 'http://localhost:8888/metrics/3.json', (err, res, body) ->
				return next err if err or res.statusCode isnt 200
				
				request.get 'http://localhost:8888/metrics/3.json', (err, res, body) ->
					return next err if err or res.statusCode isnt 200
					metrics = JSON.parse(body).metrics
					metrics.length.should.equal 0
					next()

	it 'should send 405 if request not allowed', (next) ->
		request.put 'http://localhost:8888/metrics/1.json', (err, res, body) ->
			return next err if err
			res.statusCode.should.equal 405
			next()		

