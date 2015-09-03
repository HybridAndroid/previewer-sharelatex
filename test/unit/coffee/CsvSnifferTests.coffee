SandboxedModule = require('sandboxed-module')
assert = require("chai").assert
sinon = require('sinon')
chai = require('chai')
chai.should()
expect = chai.expect
modulePath = require('path').join __dirname, '../../../app/js/CsvSniffer'
fs = require 'fs'

fixture_path = __dirname+'/../../fixtures/'


describe "CsvSniffer", ->

	beforeEach ->
		@CsvSniffer = SandboxedModule.require modulePath, requires:
			"logger-sharelatex": @logger = { log: sinon.stub(), setHeader: sinon.stub() }
			"./Errors": @Errors =
				SnifferError: sinon.stub()
			"csv-sniffer": require('csv-sniffer')

		@load = (file_path, callback) ->
			fs.readFile @file_path, {encoding: 'utf8'}, (err, data) =>
				throw err if err?
				callback data

	describe "with a simple csv file", ->

		beforeEach ->
			@file_path = fixture_path + 'simple.csv'

		it "should not produce an error", (done) ->
			@load @file_path, (sample) =>
				@CsvSniffer.sniff sample, (err, data) ->
					expect(err).to.equal null
					done()

		it "should find an array of records from the file", (done) ->
			@load @file_path, (sample) =>
				@CsvSniffer.sniff sample, (err, data) =>
					expect(data.records).to.not.equal null
					expect(data.records.length).to.equal 5
					done()

		it "should not report any warnings", (done) ->
			@load @file_path, (sample) =>
				@CsvSniffer.sniff sample, (err, data) ->
					data.warnings.should.be.Array
					data.warnings.length.should.equal 0
					done()

		it "should get the delimiter", (done) ->
			@load @file_path, (sample) =>
				@CsvSniffer.sniff sample, (err, data) ->
					data.delimiter.should.equal ','
					done()

		it "should get the quote char, which is null", (done) ->
			@load @file_path, (sample) =>
				@CsvSniffer.sniff sample, (err, data) ->
					expect(data.quoteChar).to.equal null
					done()

		it "should get the line separator", (done) ->
			@load @file_path, (sample) =>
				@CsvSniffer.sniff sample, (err, data) ->
					expect(data.newlineStr).to.equal '\n'
					done()

	describe "with a simple csv file with quoted fields", ->

		beforeEach ->
			@file_path = fixture_path + 'simple_quoted.csv'

		it "should not produce an error", (done) ->
			@load @file_path, (sample) =>
				@CsvSniffer.sniff sample, (err, data) ->
					expect(err).to.equal null
					done()

		it "should not report any warnings", (done) ->
			@load @file_path, (sample) =>
				@CsvSniffer.sniff sample, (err, data) ->
					data.warnings.should.be.Array
					data.warnings.length.should.equal 0
					done()

		it "should get the delimiter", (done) ->
			@load @file_path, (sample) =>
				@CsvSniffer.sniff sample, (err, data) ->
					data.delimiter.should.equal ','
					done()

		it 'should get the quote char, which is `"`', (done) ->
			@load @file_path, (sample) =>
				@CsvSniffer.sniff sample, (err, data) ->
					expect(data.quoteChar).to.equal '"'
					done()

		it "should get the line separator", (done) ->
			@load @file_path, (sample) =>
				@CsvSniffer.sniff sample, (err, data) ->
					expect(data.newlineStr).to.equal '\n'
					done()

	describe "with an invalid csv file", ->

		beforeEach ->
			@file_path = fixture_path + 'invalid.csv'

		it "should not produce an error", (done) ->
			@load @file_path, (sample) =>
				@CsvSniffer.sniff sample, (err, data) ->
					expect(err).to.equal null
					done()

		it "should not report any warnings", (done) ->
			@load @file_path, (sample) =>
				@CsvSniffer.sniff sample, (err, data) ->
					data.warnings.should.be.Array
					data.warnings.length.should.equal 0
					done()

		it "should not find a delimiter", (done) ->
			@load @file_path, (sample) =>
				@CsvSniffer.sniff sample, (err, data) ->
					expect(data.delimiter).to.equal null
					done()

		it "should not find a quote char", (done) ->
			@load @file_path, (sample) =>
				@CsvSniffer.sniff sample, (err, data) ->
					expect(data.quoteChar).to.equal null
					done()

		it "should get the line separator", (done) ->
			@load @file_path, (sample) =>
				@CsvSniffer.sniff sample, (err, data) ->
					expect(data.newlineStr).to.equal '\n'
					done()


	describe "with an empty sample", ->

		beforeEach ->
			@file_path = null

		it "should produce an error", (done) ->
			@CsvSniffer.sniff "", (err, data) ->
				expect(err).to.not.equal null
				expect(data).to.equal null
				done()
