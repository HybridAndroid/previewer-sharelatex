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

	describe "with a simple csv file", ->

		beforeEach ->
			@file_path = fixture_path + 'simple.csv'

		it "should not produce an error", (done) ->
			fs.readFile @file_path, {encoding: 'utf8'}, (err, sample) =>
				@CsvSniffer.sniff sample, (err, data) ->
					expect(err).to.equal null
					done()

		it "should not report any warnings", (done) ->
			fs.readFile @file_path, {encoding: 'utf8'}, (err, sample) =>
				@CsvSniffer.sniff sample, (err, data) ->
					data.warnings.should.be.Array
					data.warnings.length.should.equal 0
					done()

		it "should get the delimiter", (done) ->
			fs.readFile @file_path, {encoding: 'utf8'}, (err, sample) =>
				@CsvSniffer.sniff sample, (err, data) ->
					data.delimiter.should.equal ','
					done()

		it "should get the quote char, which is null", (done) ->
			fs.readFile @file_path, {encoding: 'utf8'}, (err, sample) =>
				@CsvSniffer.sniff sample, (err, data) ->
					expect(data.quoteChar).to.equal null
					done()

		it "should get the line separator", (done) ->
			fs.readFile @file_path, {encoding: 'utf8'}, (err, sample) =>
				@CsvSniffer.sniff sample, (err, data) ->
					expect(data.newlineStr).to.equal '\n'
					done()

	describe "with a simple csv file with quoted fields", ->

		beforeEach ->
			@file_path = fixture_path + 'simple_quoted.csv'

		it "should not produce an error", (done) ->
			fs.readFile @file_path, {encoding: 'utf8'}, (err, sample) =>
				@CsvSniffer.sniff sample, (err, data) ->
					expect(err).to.equal null
					done()

		it "should not report any warnings", (done) ->
			fs.readFile @file_path, {encoding: 'utf8'}, (err, sample) =>
				@CsvSniffer.sniff sample, (err, data) ->
					data.warnings.should.be.Array
					data.warnings.length.should.equal 0
					done()

		it "should get the delimiter", (done) ->
			fs.readFile @file_path, {encoding: 'utf8'}, (err, sample) =>
				@CsvSniffer.sniff sample, (err, data) ->
					data.delimiter.should.equal ','
					done()

		it 'should get the quote char, which is `"`', (done) ->
			fs.readFile @file_path, {encoding: 'utf8'}, (err, sample) =>
				@CsvSniffer.sniff sample, (err, data) ->
					expect(data.quoteChar).to.equal '"'
					done()

		it "should get the line separator", (done) ->
			fs.readFile @file_path, {encoding: 'utf8'}, (err, sample) =>
				@CsvSniffer.sniff sample, (err, data) ->
					expect(data.newlineStr).to.equal '\n'
					done()

	describe "with an invalid csv file", ->

		beforeEach ->
			@file_path = fixture_path + 'invalid.csv'

		it "should not produce an error", (done) ->
			fs.readFile @file_path, {encoding: 'utf8'}, (err, sample) =>
				@CsvSniffer.sniff sample, (err, data) ->
					expect(err).to.equal null
					done()

		it "should not report any warnings", (done) ->
			fs.readFile @file_path, {encoding: 'utf8'}, (err, sample) =>
				@CsvSniffer.sniff sample, (err, data) ->
					data.warnings.should.be.Array
					data.warnings.length.should.equal 0
					done()

		it "should not find a delimiter", (done) ->
			fs.readFile @file_path, {encoding: 'utf8'}, (err, sample) =>
				@CsvSniffer.sniff sample, (err, data) ->
					expect(data.delimiter).to.equal null
					done()

		it "should not find a quote char", (done) ->
			fs.readFile @file_path, {encoding: 'utf8'}, (err, sample) =>
				@CsvSniffer.sniff sample, (err, data) ->
					expect(data.quoteChar).to.equal null
					done()

		it "should get the line separator", (done) ->
			fs.readFile @file_path, {encoding: 'utf8'}, (err, sample) =>
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
