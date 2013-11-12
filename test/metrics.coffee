{exec} = require 'child_process'
should = require 'should'

describe 'metrics', ->
	metrics = null

	before (next) ->
		exec "rm -rf #{__dirname}/../db/test && mkdir #{__dirname}/../db/test", (err, stdout) ->
			throw err if err
			metrics = require '../lib/metrics'
			next()

	it 'should get a metric', (next) ->

		met = [
			timestamp:(new Date '2013-11-04 14:00 UTC').getTime(), value:1234
		,
			timestamp:(new Date '2013-11-04 14:10 UTC').getTime(), value:5678 
		]

		metrics.save 1, met, (err) ->	
			throw err if err
			metrics.get 1, (err, metrics) ->
				throw err if err
				metrics.length.should.equal 2
				[m1, m2] = metrics
				m1.timestamp.should.equal (new Date '2013-11-04 14:00 UTC').getTime()
				m1.value.should.equal 1234
				m2.timestamp.should.equal m1.timestamp + 10*60*1000
				next()

	it 'should remove a metric', (next) ->

		met = [
			timestamp:(new Date '2013-12-04 15:00 UTC').getTime(), value:123
		,
			timestamp:(new Date '2013-12-04 15:10 UTC').getTime(), value:456 
		]

		metrics.save 2, met, (err) ->
			throw err if err
			metrics.delete 2, (err) ->
				throw err if err
				metrics.get 2, (err, metrics) ->
					metrics.length.should.equal(0)
					next()