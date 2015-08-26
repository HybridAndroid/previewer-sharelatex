SandboxedModule = require('sandboxed-module')
assert = require("chai").assert
sinon = require('sinon')
chai = require('chai')
chai.should()
expect = chai.expect
modulePath = require('path').join __dirname, '../../../app/js/CsvSniffer'

fixture_path = __dirname+'/../../fixtures/'


describe "CsvSniffer", ->

	beforeEach ->
		@CsvSniffer = SandboxedModule.require modulePath, requires:
			"logger-sharelatex": @logger = { log: sinon.stub(), setHeader: sinon.stub() }
			"./Errors": @Errors = {}
			"csv-sniffer": require('csv-sniffer')
			"fs": require('fs')

	describe "with a missing csv file", ->

		beforeEach ->
			@file_path = fixture_path + 'a_file_which_does_not_exist.csv'

		it "should produce an error", (done) ->
			@CsvSniffer.sniff @file_path, (err, data) ->
				expect(err).to.not.equal null
				err.code.should.equal 'ENOENT'
				expect(data).to.equal null
				done()

	describe "with a simple csv file", ->

		beforeEach ->
			@file_path = fixture_path + 'simple.csv'

		it "should not produce an error", (done) ->
			@CsvSniffer.sniff @file_path, (err, data) ->
				expect(err).to.equal null
				done()

		it "should not report any warnings", (done) ->
			@CsvSniffer.sniff @file_path, (err, data) ->
				data.warnings.should.be.Array
				data.warnings.length.should.equal 0
				done()

		it "should get the delimiter", (done) ->
			@CsvSniffer.sniff @file_path, (err, data) ->
				data.delimiter.should.equal ','
				done()

		it "should get the quote char, which is null", (done) ->
			@CsvSniffer.sniff @file_path, (err, data) ->
				expect(data.quoteChar).to.equal null
				done()

		it "should get the line separator", (done) ->
			@CsvSniffer.sniff @file_path, (err, data) ->
				expect(data.newlineStr).to.equal '\n'
				done()

	describe "with a simple csv file with quoted fields", ->

		beforeEach ->
			@file_path = fixture_path + 'simple_quoted.csv'

		it "should not produce an error", (done) ->
			@CsvSniffer.sniff @file_path, (err, data) ->
				expect(err).to.equal null
				done()

		it "should not report any warnings", (done) ->
			@CsvSniffer.sniff @file_path, (err, data) ->
				data.warnings.should.be.Array
				data.warnings.length.should.equal 0
				done()

		it "should get the delimiter", (done) ->
			@CsvSniffer.sniff @file_path, (err, data) ->
				data.delimiter.should.equal ','
				done()

		it 'should get the quote char, which is `"`', (done) ->
			@CsvSniffer.sniff @file_path, (err, data) ->
				expect(data.quoteChar).to.equal '"'
				done()

		it "should get the line separator", (done) ->
			@CsvSniffer.sniff @file_path, (err, data) ->
				expect(data.newlineStr).to.equal '\n'
				done()
