{exec} = require 'child_process'
should = require 'should'

describe 'users', ->
	users = null
	metrics = null

	before (next) ->
		exec "rm -rf #{__dirname}/../db/users && mkdir #{__dirname}/../db/users", (err, stdout) ->
			throw err if err
			users = require '../lib/users'
			metrics = require '../lib/metrics'
			next()

	describe 'save() get()', ->

		it 'should save and get a user', (next) ->
			user =
				email: "thibaultcha@me.com"
				password : "1234"
				name: "Thibault"

			users.save user, (err) ->
				throw err if err
				users.get user.email, (err, user) ->
					throw err if err
					user.should.be.an.instanceOf(Object)
					user.email.should.equal 'thibaultcha@me.com'
					user.password.should.equal '1234'
					user.name.should.equal 'Thibault'
					next()

		it 'should return null for a non existing user', (next) ->
			users.get "wrong@domain.com", (err, user) ->
				next err if err
				(user == null).should.be.true
				next()

	describe 'delete()', ->

		it 'should delete a user', (next) ->
			user =
				email: "thibaultcha@me.com"

			users.save user, (err) ->
				throw err if err
				users.delete user.email, (err) ->
					throw err if err
					users.get user.email, (err, user) ->
						(user == null).should.be.true
						next()

	describe 'addMetrics() getMetrics()', ->

		it 'should add an existing metric to an existing user', (next) ->
			user =
				email: "name@domain.com"

			met = [
				timestamp:(new Date '2013-11-04 14:00 UTC').getTime(), value:1234
			,
				timestamp:(new Date '2013-11-04 14:10 UTC').getTime(), value:5678
			]

			metrics.save 3, met, (err) ->
				next err if err
				users.save user, (err) ->
					next err if err
					users.addMetrics user, 3, (err) ->
						next err if err					
						users.getMetrics user, (err, user_metrics) ->
							next err if err
							user_metrics.should.be.an.instanceOf(Array)
							user_metrics[0].timestamp.should.equal met[0].timestamp
							user_metrics[1].timestamp.should.equal met[1].timestamp
							next()

		it.skip 'should throw an error if user does not exist', (next) ->
			user =
				email: "oiuezafiazuefh@domain.com"

			users.addMetrics user, 4, (err) ->
				throw err if err
				next()

	describe 'getMetrics()', ->

		it.skip 'should return an empty array if no metrics for id', (next) ->
			user = 
				email: "user@domain.com"

			users.save user, (err) ->
				next err if err
				users.getMetrics user, (err, user_metrics) ->
					next err if err
					user_metrics.should.be.an.instanceOf(Array)
					user_metrics.length.should.equal 0
					next()

		it.skip 'should throw an error if user does not exist', (next) ->
			user =
				email: "qezfuoyzguyg@domain.com"

			users.getMetrics user, (err) ->
				next err if err
				next()

	after (next) ->
		exec "rm -rf #{__dirname}/../db/users", (err, stdout) ->
			next err if err
			next()
