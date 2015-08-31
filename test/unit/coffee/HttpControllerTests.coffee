SandboxedModule = require('sandboxed-module')
assert = require("chai").assert
sinon = require('sinon')
chai = require('chai')
chai.should()
expect = chai.expect
modulePath = require('path').join __dirname, '../../../app/js/HttpController'
ObjectId = require("mongojs").ObjectId

describe "HttpController", ->

	beforeEach ->
		@HttpController = SandboxedModule.require modulePath, requires:
			"logger-sharelatex": @logger = { log: sinon.stub(), setHeader: sinon.stub() }
			"./Errors": @Errors = {}
		@req = {}
		@res = {}

	describe "_build_csv_preview", ->

		beforeEach ->
			@details =
				records: [
					['one', 'two'],
					['three', 'four']
				]
				delimiter: ','
				quoteChar: '"'
				newlineStr: '\n'
				types: ['string', 'string']
				labels: ['Column One', 'Column Two']
			@file_url = "http://example.com/somewhere"

		it "should have a source attribute", (done) ->
			preview = @HttpController._build_csv_preview @file_url, @details
			preview.source.should.equal @file_url
			done()

		it "should have a rows attribute", (done) ->
			preview = @HttpController._build_csv_preview @file_url, @details
			preview.rows.should.deep.equal @details.records
			done()

		it "should have a delimiter attribute", (done) ->
			preview = @HttpController._build_csv_preview @file_url, @details
			preview.delimiter.should.equal @details.delimiter
			done()

		it "should have a quoteChar attribute", (done) ->
			preview = @HttpController._build_csv_preview @file_url, @details
			preview.quoteChar.should.equal @details.quoteChar
			done()

		it "should have a newlineStr attribute", (done) ->
			preview = @HttpController._build_csv_preview @file_url, @details
			preview.newlineStr.should.equal @details.newlineStr
			done()

		it "should have a types attribute", (done) ->
			preview = @HttpController._build_csv_preview @file_url, @details
			preview.types.should.equal @details.types
			done()

		it "should have a labels attribute", (done) ->
			preview = @HttpController._build_csv_preview @file_url, @details
			preview.labels.should.equal @details.labels
			done()
