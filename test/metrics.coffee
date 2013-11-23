{exec} = require 'child_process'
should = require 'should'

describe 'metrics', ->
	metrics = null

	before (next) ->
		exec "rm -rf #{__dirname}/../db/metrics && mkdir #{__dirname}/../db/metrics", (err, stdout) ->
			throw err if err
			metrics = require '../lib/metrics'
			next()

	it 'should save and get a metric', (next) ->
		met = [
			timestamp:(new Date '2013-11-04 14:00 UTC').getTime(), value:1234
		,
			timestamp:(new Date '2013-11-04 14:10 UTC').getTime(), value:5678
		,
			timestamp:(new Date '2013-11-04 14:11 UTC').getTime(), value:9101
		]

		metrics.save 1, met, (err) ->
			throw err if err
			metrics.get 1, (err, metrics) ->
				throw err if err
				metrics.length.should.equal 3
				[m1, m2, m3] = metrics
				
				m1.id.should.equal 1
				m2.id.should.equal 1
				m3.id.should.equal 1
				
				m1.value.should.equal 1234
				m3.value.should.equal 9101

				m1.timestamp.should.equal (new Date '2013-11-04 14:00 UTC').getTime()
				m2.timestamp.should.equal m1.timestamp + 10*60*1000
				
				next()

	it 'should delete a metric', (next) ->
		met = [
			timestamp:(new Date '2013-12-04 15:00 UTC').getTime(), value:123
		,
			timestamp:(new Date '2013-12-04 15:10 UTC').getTime(), value:456,
		,
			timestamp:(new Date '2013-11-04 14:11 UTC').getTime(), value:789
		]

		metrics.save 2, met, (err) ->
			throw err if err
			metrics.delete 2, (err) ->
				throw err if err
				metrics.get 2, (err, metrics) ->
					metrics.length.should.equal 0
					next()

	after (next) ->
		exec "rm -rf #{__dirname}/../db/metrics", (err, stdout) ->
			throw err if err
			next()
