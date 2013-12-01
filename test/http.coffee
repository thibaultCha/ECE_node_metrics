{exec}  = require 'child_process'
should  = require 'should'
request = require 'request'

describe 'REST API', ->

	describe 'metrics', ->

		it 'should post and get a metric', (next) ->
			met = [
				timestamp:(new Date '2013-11-04 14:00 UTC').getTime(), value:3
			,
				timestamp:(new Date '2013-11-04 14:10 UTC').getTime(), value:4 
			]

			request.post 'http://localhost:8888/metrics/2.json', { form: { metrics: met } }, (err, res, body) ->
				return next err if err
				return next new Error "Post failed. status: #{res.statusCode} #{res.body}" if res.statusCode isnt 200
				fetched_metrics = JSON.parse(body).metrics
				fetched_metrics.length.should.equal 2
				[m1, m2] = fetched_metrics
				m1.id.should.equal 2
				m2.id.should.equal 2
				m1.value.should.equal 3
				m2.value.should.equal 4

				request.get 'http://localhost:8888/metrics/2.json', (err, res, body) ->
					return next err if err
					return next new Error "Get failed. status: #{res.statusCode} #{res.body}" if res.statusCode isnt 200
					fetched_metrics = JSON.parse(body).metrics
					fetched_metrics.length.should.equal 2
					[m1, m2] = fetched_metrics
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
				return next err if err
				return next new Error "Post failed. status: #{res.statusCode} #{res.body}" if res.statusCode isnt 200
				
				request.del 'http://localhost:8888/metrics/3.json', (err, res, body) ->
					return next err if err
					return next new Error "Delete failed. status: #{res.statusCode} #{res.body}" if res.statusCode isnt 200
					
					request.get 'http://localhost:8888/metrics/3.json', (err, res) ->
						return next err if err
						res.statusCode.should.equal 404
						next()

		it 'should return 404 if no metrics for id', (next) ->
			request.get 'http://localhost:8888/metrics/9999.json', (err, res) ->
				return next err if err
				res.statusCode.should.equal 404
				next()

		it 'should return 404 if no metric for id on delete', (next) ->
			request.del 'http://localhost:8888/metrics/9999.json', (err, res) ->
				return next err if err
				res.statusCode.should.equal 404
				next()

	###
		it 'should send 405 if request not allowed', (next) ->
			request.put 'http://localhost:8888/metrics/1.json', (err, res, body) ->
				return next err if err
				res.statusCode.should.equal 405
				next()
	###

	describe 'users', ->

		# we have to test all three here otherwise we get a 
		# "user already exists" if we run the tests more than once
		it 'should post, get and delete a user', (next) ->
			@slow(200)
			user =
				email:"postget@domain.com"
				name:"name"
				password:"1234"

			request.post 'http://localhost:8888/users.json', { form: { user: user } }, (err, res, body) ->
				return next if err 
				return next new Error "Post failed. status: #{res.statusCode} #{res.body}" if res.statusCode isnt 200
				saved_user = JSON.parse(body)
				saved_user.name.should.equal user.name
				saved_user.email.should.equal user.email
				request.get "http://localhost:8888/users/#{user.email}.json", (err, res, body) ->
					return next err if err
					return next new Error "Get failed. status: #{res.statusCode} #{res.body}" if res.statusCode isnt 200
					fetched_user = JSON.parse(body)
					fetched_user.name.should.equal user.name
					request.del 'http://localhost:8888/users/postget@domain.com.json', (err, res, body) ->
						return next err if err
						return next new Error "Delete failed. status: #{res.statusCode} #{res.body}" if res.statusCode isnt 200
						next()	

		it 'should return 404 on get a non existent user', (next) ->
			user =
				email:"user404@domain.com"
				name:"name"
				password:"1234"

			request.get "http://localhost:8888/users/#{user.email}.json", (err, res, body) ->
				return next err if err
				res.statusCode.should.equal 404
				next()

		it 'should return 404 on delete a non existent user', (next) ->
			user =
				email:"user404@domain.com"
				name:"name"
				password:"1234"

			request.del "http://localhost:8888/users/#{user.email}.json", (err, res, body) ->
				return next err if err
				res.statusCode.should.equal 404
				next()

	describe 'users_metrics', ->
		user =
			email: "user_metrics@domain.com"
			password: "123456"
			name: "name"

		before (next) ->
			met_id = 1
			met = [
				timestamp:(new Date '2013-12-21 14:00 UTC').getTime(), value:120
			,
				timestamp:(new Date '2013-12-22 14:10 UTC').getTime(), value:287
			]
			request.post "http://localhost:8888/metrics/#{met_id}.json", { form: { metrics: met } }, (err, res, body) ->
				return next err if err
				return next new Error "Post failed. status: #{res.statusCode} #{res.body}" if res.statusCode isnt 200
				request.post 'http://localhost:8888/users.json', { form: { user: user } }, (err, res, body) ->
					return next if err 
					return next new Error "Post failed. status: #{res.statusCode} #{res.body}" if res.statusCode isnt 200
					request.post "http://localhost:8888/users/#{user.email}/metrics.json", { form: { metrics_id: met_id } }, (err, res, body) ->
						return next if err 
						return next new Error "Post failed. status: #{res.statusCode} #{res.body}" if res.statusCode isnt 200
						next()

		it 'should add and return metrics for a user', (next) ->
			request.get "http://localhost:8888/users/#{user.email}/metrics.json", (err, res, body) ->
				return next err if err
				return next new Error "Get failed. status: #{res.statusCode} #{res.body}" if res.statusCode isnt 200
				fetched_metrics = JSON.parse(body)[0].metrics
				fetched_metrics.length.should.equal 2
				fetched_metrics[0].value.should.equal 120
				next()

		after (next) ->
			request.del "http://localhost:8888/users/#{user.email}.json", { form: { user: user } }, (err, res, body) ->
				return next if err 
				return next new Error "Post failed. status: #{res.statusCode} #{res.body}" if res.statusCode isnt 200
				next()
