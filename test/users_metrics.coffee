{exec} = require 'child_process'
should = require 'should'

describe 'users_metrics', ->
	users = null
	metrics = null
	uMetrics = null

	before (next) ->
		exec "rm -rf #{__dirname}/../db/users-metrics && mkdir #{__dirname}/../db/users-metrics", (err, stdout) ->
			return next err if err
			users = require '../lib/users'
			metrics = require '../lib/metrics'
			uMetrics = require '../lib/users_metrics'
			next()

	describe 'addMetrics()', ->

		it 'should add an existing metric to an existing user', (next) ->
			user =
				email: "add@domain.com"

			met = [
				timestamp:(new Date '2013-11-04 14:00 UTC').getTime(), value:1234
			,
				timestamp:(new Date '2013-11-04 14:10 UTC').getTime(), value:5678
			]

			metrics.save 3, met, (err) ->
				return next err if err
				metrics.save 4, met, (err) ->
					return next err if err
					users.save user, (err) ->
						return next err if err
						uMetrics.addMetrics user.email, 3, (err) ->
							return next err if err
							uMetrics.addMetrics user.email, 4, (err) ->
								return next err if err	
								uMetrics.getMetrics user.email, (err, user_metrics) ->
									return next err if err
									user_metrics.should.be.an.instanceOf(Array)
									user_metrics.length.should.equal 2
									user_metrics[0].id.should.equal 4
									user_metrics[0].metrics.should.be.an.instanceOf(Array)
									user_metrics[0].metrics[0].value.should.be.equal 1234
									next()

		it 'should return an error if user does not exist', (next) ->
			user =
				email: "addwrong@domain.com"

			uMetrics.addMetrics user.email, 0, (err) ->
				err.should.not.be.null
				next()

		it 'should return an error if metric_id does not exist', (next) ->
			user =
				email: "adderror@domain.com"

			users.save user, (err) ->
				return next err if err
				uMetrics.addMetrics user.email, 9999, (err) ->
					err.should.not.be.null
					next()

	describe 'getMetrics()', ->

		it 'should return an empty array if no metrics for id', (next) ->
			user = 
				email: "get@domain.com"

			users.save user, (err) ->
				return next err if err
				uMetrics.getMetrics user.email, (err, user_metrics) ->
					return next err if err
					user_metrics.should.be.an.instanceOf(Array)
					user_metrics.length.should.equal 0
					next()

		it 'should return an error if user does not exist', (next) ->
			user =
				email: "getwrong@domain.com"

			uMetrics.getMetrics user.email, (err) ->
				err.should.not.be.null
				next()

	describe 'removeMetrics()', ->

		it 'should return an error if user does not exist', (next) ->
			user =
				email: "removewrong@domain.com"

			uMetrics.removeMetrics user.email, 1, (err) ->
				err.should.not.be.null
				next()

		it 'should return an error if trying to remove a metrics not attached to user', (next) ->
			user =
				email: "removeerror@domain.com"

			users.save user, (err) ->
				return next err if err
				uMetrics.removeMetrics user.email, 9999, (err) ->
					err.should.not.be.null
					next()

		it 'should remove attached metric to existing user', (next) ->
			user =
				email: "remove@domain.com"

			met = [
				timestamp:(new Date '2013-11-04 14:00 UTC').getTime(), value:1234
			,
				timestamp:(new Date '2013-11-04 14:10 UTC').getTime(), value:5678
			]

			users.save user, (err) ->
				return next err if err
				metrics.save 1, met, (err) ->
					return next err if err
					uMetrics.addMetrics user.email, 1, (err) ->
						return next err if err
						uMetrics.getMetrics user.email, (err, user_metrics) ->
							return next err if err
							user_metrics.should.be.an.instanceOf(Array)
							user_metrics.length.should.equal 1
							user_metrics[0].metrics[0].value.should.equal 1234
							uMetrics.removeMetrics user.email, 1, (err) ->
								return next err if err
								uMetrics.getMetrics user.email, (err, final_metrics) ->
									return next err if err
									final_metrics.length.should.be.equal 0
									next()

	after (next) ->
		exec "rm -rf #{__dirname}/../db/users-metrics", (err, stdout) ->
			return next err if err
			next()
