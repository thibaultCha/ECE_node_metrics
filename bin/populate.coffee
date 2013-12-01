#!/usr/bin/env coffee
{exec}   = require 'child_process'

exec "rm -rf #{__dirname}/../db/*", (err, stdout) ->
	throw err if err
	metrics  = require '../lib/metrics'
	users    = require '../lib/users'
	uMetrics = require '../lib/users_metrics'

	user =
		email: "name@domain.com"
		password: "123456"
		name: "User 1"
	met_ids = [1,2]

	met = [
				timestamp:(new Date '2013-12-21 14:00 UTC').getTime(), value:120
			,
				timestamp:(new Date '2013-12-22 14:10 UTC').getTime(), value:287
			,
				timestamp:(new Date '2013-12-23 14:11 UTC').getTime(), value:397
			,
				timestamp:(new Date '2013-12-24 14:11 UTC').getTime(), value:466
			,
				timestamp:(new Date '2013-12-25 14:00 UTC').getTime(), value:655
			,
				timestamp:(new Date '2013-12-27 14:10 UTC').getTime(), value:987
			,
				timestamp:(new Date '2013-12-29 14:11 UTC').getTime(), value:969
			,
				timestamp:(new Date '2013-12-30 14:11 UTC').getTime(), value:867
			,
				timestamp:(new Date '2014-12-01 14:11 UTC').getTime(), value:935
			]

	met2 = [
				timestamp:(new Date '2014-12-02 14:11 UTC').getTime(), value:979
			,
				timestamp:(new Date '2014-12-07 14:11 UTC').getTime(), value:993
			,
				timestamp:(new Date '2014-01-08 14:00 UTC').getTime(), value:967
			,
				timestamp:(new Date '2014-01-09 14:10 UTC').getTime(), value:768
			,
				timestamp:(new Date '2014-01-10 14:11 UTC').getTime(), value:654
			,
				timestamp:(new Date '2014-01-11 14:11 UTC').getTime(), value:765
			,
				timestamp:(new Date '2014-01-12 14:11 UTC').getTime(), value:668
			,
				timestamp:(new Date '2014-01-13 14:11 UTC').getTime(), value:550
			,
				timestamp:(new Date '2014-01-14 14:11 UTC').getTime(), value:340
			]

	metrics.save met_ids[0], met, (err) ->
		throw err if err
		metrics.save met_ids[1], met2, (err) ->
			throw err if err
			users.save user, (err) ->
				throw err if err
				uMetrics.addBatchMetrics user.email, [1,2], (err) ->
					throw err if err
					console.log "New User"
					console.log "email: #{user.email}"
					console.log "password: 123456"
					console.log "Metrics: #{met_ids}"
					console.log ''
					user =
						email: "name2@domain.com"
						password: "123456"
						name: "User 2"
					met_ids = [3,4]

					met = [
								timestamp:(new Date '2013-12-21 14:00 UTC').getTime(), value:120
							,
								timestamp:(new Date '2013-12-22 14:10 UTC').getTime(), value:287
							,
								timestamp:(new Date '2013-12-23 14:11 UTC').getTime(), value:397
							,
								timestamp:(new Date '2013-12-24 14:11 UTC').getTime(), value:466
							,
								timestamp:(new Date '2013-12-25 14:00 UTC').getTime(), value:655
							,
								timestamp:(new Date '2013-12-27 14:10 UTC').getTime(), value:987
							,
								timestamp:(new Date '2013-12-29 14:11 UTC').getTime(), value:969
							,
								timestamp:(new Date '2013-12-30 14:11 UTC').getTime(), value:867
							,
								timestamp:(new Date '2014-12-01 14:11 UTC').getTime(), value:935
							]

					met2 = [
								timestamp:(new Date '2014-12-02 14:11 UTC').getTime(), value:979
							,
								timestamp:(new Date '2014-12-07 14:11 UTC').getTime(), value:993
							,
								timestamp:(new Date '2014-01-08 14:00 UTC').getTime(), value:967
							,
								timestamp:(new Date '2014-01-09 14:10 UTC').getTime(), value:768
							,
								timestamp:(new Date '2014-01-10 14:11 UTC').getTime(), value:654
							,
								timestamp:(new Date '2014-01-11 14:11 UTC').getTime(), value:765
							,
								timestamp:(new Date '2014-01-12 14:11 UTC').getTime(), value:668
							,
								timestamp:(new Date '2014-01-13 14:11 UTC').getTime(), value:550
							,
								timestamp:(new Date '2014-01-14 14:11 UTC').getTime(), value:340
							]

					metrics.save met_ids[0], met, (err) ->
						throw err if err
						metrics.save met_ids[1], met2, (err) ->
							throw err if err
							users.save user, (err) ->
								throw err if err
								uMetrics.addBatchMetrics user.email, [3,4], (err) ->
									throw err if err
									console.log "New User"
									console.log "email: #{user.email}"
									console.log "password: 123456"
									console.log "Metrics: #{met_ids}"
									console.log ''
