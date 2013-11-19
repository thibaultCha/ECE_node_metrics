{exec} = require 'child_process'
should = require 'should'

describe 'users', ->
	users = null

	before (next) ->
		exec "rm -rf #{__dirname}/../db/users && mkdir #{__dirname}/../db/users", (err, stdout) ->
			throw err if err
			users = require '../lib/users'
			next()

	it 'should save and get a user', (next) ->
		user =
			email: "thibaultcha@me.com"
			name: "Thibault"

		users.save user, (err) ->
			throw err if err
			users.get user.email, (err, user) ->
				throw err if err

				user.email.should.equal 'thibaultcha@me.com'
				user.name.should.equal 'Thibault'
				
				next()

	it 'should delete a user', (next) ->
		user =
			email: "thibaultcha@me.com"
			name: "Thibault"

		users.save user, (err) ->
			throw err if err
			users.delete user.email, (err) ->
				throw err if err
				users.get user.email, (err, user) ->
					(user == null).should.be.true
					next()

	after (next) ->
		exec "rm -rf #{__dirname}/../db/users", (err, stdout) ->
			throw err if err
			next()
