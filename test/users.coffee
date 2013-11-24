{exec} = require 'child_process'
should = require 'should'
bcrypt = require 'bcrypt'
salt   = bcrypt.genSaltSync 10

describe 'users', ->
	users = null
	metrics = null

	before (next) ->
		exec "rm -rf #{__dirname}/../db/users && mkdir #{__dirname}/../db/users", (err, stdout) ->
			return next err if err
			users = require '../lib/users'
			metrics = require '../lib/metrics'
			next()

	describe 'save() get()', ->
		
		it 'should save and get a user', (next) ->
			user =
				email: "saveget@me.com"
				password : "1234"
				name: "Thibault"

			users.save user, (err, saved_user) ->
				return next err if err
				saved_user.should.equal user
				users.get user.email, (err, user) ->
					return next err if err
					user.should.be.an.instanceOf(Object)
					user.email.should.equal 'saveget@me.com'
					bcrypt.compareSync("1234", user.password).should.be.true
					user.name.should.equal 'Thibault'
					next()

		it 'should return null for a non existing user', (next) ->
			users.get "wrong@domain.com", (err, user) ->
				return next err if err
				(user == null).should.be.true
				next()

		it.skip 'should return an error if user with email already exists', (next) ->
			user =
				email: "exists@me.com"

			users.save user, (err) ->
				#return next err if err
				users.save user, (errUser) ->
					errUser.should.not.be.null
					next()

	describe 'delete()', ->

		it 'should delete a user', (next) ->
			user =
				email: "delete@me.com"

			users.save user, (err) ->
				return next err if err
				users.delete user.email, (err) ->
					return next err if err
					users.get user.email, (err, user) ->
						(user == null).should.be.true
						next()

		it 'should return an error if user does not exist', (next) ->
			user =
				email: "wrong@domain.com"			

			users.delete user.email, (err) ->
				err.should.not.be.null
				next()

	after (next) ->
		exec "rm -rf #{__dirname}/../db/users", (err, stdout) ->
			return next err if err
			next()
