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

	after (next) ->
		exec "rm -rf #{__dirname}/../db/users", (err, stdout) ->
			next err if err
			next()
