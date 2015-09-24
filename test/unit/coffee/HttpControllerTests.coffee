SandboxedModule = require('sandboxed-module')
assert = require("chai").assert
sinon = require('sinon')
chai = require('chai')
chai.should()
expect = chai.expect
modulePath = require('path').join __dirname, '../../../app/js/HttpController'
ObjectId = require("mongojs").ObjectId
fs = require('fs')

describe "HttpController", ->

	beforeEach ->
		# NOTE: isbinaryfile and path not stubbed out
		@HttpController = SandboxedModule.require modulePath, requires:
			"logger-sharelatex": @logger = { log: sinon.stub(), setHeader: sinon.stub() }
			"./FilestoreHandler": @FilestoreHandler =
				getSample: sinon.stub()
			"./CsvSniffer": @CsvSniffer =
				sniff: sinon.stub()
			"./Errors": @Errors =
				NotFoundError: sinon.stub()
			"metrics-sharelatex":
				inc: sinon.stub()
		@req = {}
		@res =
			send: ->
			setHeader: ->
		@file_url = "http://example.com/xiyueoauea"
		@file_name = "someFile.csv"
		@req.query =
			fileUrl: @file_url
			fileName: @file_name
		@sample =
			data: 'somedata'
			truncated: false
		@details =
			delimiter: ','
			records: []
		@FilestoreHandler.getSample.callsArgWith(1, null, @sample)
		@CsvSniffer.sniff.callsArgWith(1, null, @details)

	describe "_get_preview_type", ->

		beforeEach ->
			@test_data =
				'csv': [
					{filename: 'one.csv',  sample: {data: 'one,two\nthree,four'}}
					{filename: 'two.csv',  sample: {data: 'one,two,five\nthree,four,six'}}
				]
				'text': [
					{filename: 'one.txt',  sample: {data: 'one two three four'}}
					{filename: 'one',      sample: {data: 'one two three four five'}}
					{filename: 'some.log', sample: {data: 'a thing happened\nthen another thing'}}
					{filename: 'data.xyz', sample: {data: 'bihueoadrgueoa hgcrlueoaddesao'}}
				]
				'binary': [
					{
						filename: 'some-program',
						sample: {data: fs.readFileSync(__dirname+'/../../fixtures/hello-world-in-python').toString('utf-8')}
					}
				]

		it 'should produce the right preview-type based on supplied filename and sample', ->
			for expected_type, examples of @test_data
				for example in examples
					type = @HttpController._get_preview_type(example.filename, example.sample)
					type.should.equal expected_type

	describe "preview", ->

		beforeEach ->
			sinon.spy(@HttpController, '_get_preview_type')

		describe "with a fileUrl and fileName query parameter", ->

			describe "with a csv file", ->

				it "should produce a 200 response of the correct type", (done) ->
					@res.status = (code) =>
						send: (data) =>
							code.should.equal 200
							data.type.should.equal 'csv'
							data.source.should.equal @file_url
							data.filename.should.equal @file_name
							done()
					@HttpController.preview @req, @res

				it "should use the fileUrl query to get Sample from Filestore", (done) ->
					@res.status = (code) =>
						send: (data) =>
							@FilestoreHandler.getSample.calledWith(@file_url).should.equal true
							done()
					@HttpController.preview @req, @res

				it "should call _get_preview_type", (done) ->
					@res.status = (code) =>
						send: (data) =>
							@HttpController._get_preview_type.calledOnce.should.equal true
							@HttpController._get_preview_type.calledWith(@file_name, @sample).should.equal true
							done()
					@HttpController.preview @req, @res

				it "should provide the sample data to the CsvSniffer", (done) ->
					@res.status = (code) =>
						send: (data) =>
							@CsvSniffer.sniff.calledWith('somedata').should.equal true
							done()
					@HttpController.preview @req, @res

			describe "with a text file", ->

				beforeEach ->
					@file_url = "http://example.com/xiyueushqs"
					@file_name = "someFile.txt"
					@req.query =
						fileUrl: @file_url
						fileName: @file_name
					@sample =
						data: 'somedata'
						truncated: false
					@FilestoreHandler.getSample.callsArgWith(1, null, @sample)
					@CsvSniffer.sniff.callsArgWith(1, null, @details)

				it "should produce a 200 response of the correct type", (done) ->
					@res.status = (code) =>
						send: (data) =>
							code.should.equal 200
							data.type.should.equal 'text'
							data.source.should.equal @file_url
							data.filename.should.equal @file_name
							done()
					@HttpController.preview @req, @res

				it "should use the fileUrl query to get Sample from Filestore", (done) ->
					@res.status = (code) =>
						send: (data) =>
							@FilestoreHandler.getSample.calledWith(@file_url).should.equal true
							done()
					@HttpController.preview @req, @res

				it "should call _get_preview_type", (done) ->
					@res.status = (code) =>
						send: (data) =>
							@HttpController._get_preview_type.calledOnce.should.equal true
							@HttpController._get_preview_type.calledWith(@file_name, @sample).should.equal true
							done()
					@HttpController.preview @req, @res

			describe "with an extensionless text file", ->

				beforeEach ->
					@file_url = "http://example.com/xiyueushqs"
					@file_name = "someFile"
					@req.query =
						fileUrl: @file_url
						fileName: @file_name
					@sample =
						data: 'somedata'
						truncated: false
					@FilestoreHandler.getSample.callsArgWith(1, null, @sample)
					@CsvSniffer.sniff.callsArgWith(1, null, @details)

				it "should produce a 200 response of the correct type", (done) ->
					@res.status = (code) =>
						send: (data) =>
							code.should.equal 200
							data.type.should.equal 'text'
							data.source.should.equal @file_url
							data.filename.should.equal @file_name
							done()
					@HttpController.preview @req, @res

				it "should use the fileUrl query to get Sample from Filestore", (done) ->
					@res.status = (code) =>
						send: (data) =>
							@FilestoreHandler.getSample.calledWith(@file_url).should.equal true
							done()
					@HttpController.preview @req, @res

				it "should call _get_preview_type", (done) ->
					@res.status = (code) =>
						send: (data) =>
							@HttpController._get_preview_type.calledOnce.should.equal true
							@HttpController._get_preview_type.calledWith(@file_name, @sample).should.equal true
							done()
					@HttpController.preview @req, @res


			describe "with an extensionless weird binary file", ->

				beforeEach ->
					@file_url = "http://example.com/xiyhshtlc"
					@file_name = "some-program"
					@req.query =
						fileUrl: @file_url
						fileName: @file_name
					@sample =
						data: fs.readFileSync(__dirname + '/../../fixtures/hello-world-in-python').toString('utf-8')
						truncated: false
					@FilestoreHandler.getSample.callsArgWith(1, null, @sample)
					@CsvSniffer.sniff.callsArgWith(1, null, @details)

				it "should produce a 200 response of the correct type", (done) ->
					@res.status = (code) =>
						send: (data) =>
							code.should.equal 200
							data.type.should.equal 'binary'
							data.source.should.equal @file_url
							data.filename.should.equal @file_name
							done()
					@HttpController.preview @req, @res

				it "should use the fileUrl query to get Sample from Filestore", (done) ->
					@res.status = (code) =>
						send: (data) =>
							@FilestoreHandler.getSample.calledWith(@file_url).should.equal true
							done()
					@HttpController.preview @req, @res

				it "should call _get_preview_type", (done) ->
					@res.status = (code) =>
						send: (data) =>
							@HttpController._get_preview_type.calledOnce.should.equal true
							@HttpController._get_preview_type.calledWith(@file_name, @sample).should.equal true
							done()
					@HttpController.preview @req, @res

		describe "without a fileUrl or fileName", ->

			beforeEach ->
				@req.query = {}

			it "should produce an error code", (done) ->
				@res.status = (code) =>
					send: (data) =>
						code.should.equal 400
						done()
				@HttpController.preview @req, @res

		describe "when the filestore cannot find the file", ->

			it "should produce a 404 response", (done) ->
				@FilestoreHandler.getSample.callsArgWith(1, new @Errors.NotFoundError(), null)
				@res.sendStatus = (code) =>
					code.should.equal 404
					done()
				@HttpController.preview @req, @res


describe "HttpController old", ->

	beforeEach ->
		# NOTE: isbinaryfile and path not stubbed out
		@HttpController = SandboxedModule.require modulePath, requires:
			"logger-sharelatex": @logger = { log: sinon.stub(), setHeader: sinon.stub() }
			"./FilestoreHandler": @FilestoreHandler =
				getSample: sinon.stub()
			"./CsvSniffer": @CsvSniffer =
				sniff: sinon.stub()
			"./Errors": @Errors =
				NotFoundError: sinon.stub()
			"metrics-sharelatex":
				inc: sinon.stub()
		@req = {}
		@res =
			send: ->
			setHeader: ->
		@file_url = "http://example.com/xiyueoauea"
		@file_name = "someFile.csv"
		@req.query =
			fileUrl: @file_url
			fileName: @file_name
		@sample =
			data: 'somedata'
			truncated: false
		@details =
			delimiter: ','
		@FilestoreHandler.getSample.callsArgWith(1, null, @sample)
		@CsvSniffer.sniff.callsArgWith(1, null, @details)

	describe "previewCsv", ->

		describe "with a fileUrl query parameter", ->

			it "should produce a 200 response", (done) ->
				@res.status = (code) =>
					send: (data) =>
						code.should.equal 200
						data.source.should.equal @file_url
						data.delimiter.should.equal ','
						done()
				@HttpController.previewCsv @req, @res

			it "should use the fileUrl query to get Sample from Filestore", (done) ->
				@res.status = (code) =>
					send: (data) =>
						@FilestoreHandler.getSample.calledWith(@file_url).should.equal true
						done()
				@HttpController.previewCsv @req, @res

			it "should provide the sample data to the CsvSniffer", (done) ->
				@res.status = (code) =>
					send: (data) =>
						@CsvSniffer.sniff.calledWith('somedata').should.equal true
						done()
				@HttpController.previewCsv @req, @res

		describe "without a fileUrl", ->

			beforeEach ->
				@req.query = {}

			it "should produce an error code", (done) ->
				@res.status = (code) =>
					send: (data) =>
						code.should.equal 400
						done()
				@HttpController.previewCsv @req, @res

		describe "when the filestore cannot find the file", ->

			it "should produce a 404 response", (done) ->
				@FilestoreHandler.getSample.callsArgWith(1, new @Errors.NotFoundError(), null)
				@res.sendStatus = (code) =>
					code.should.equal 404
					done()
				@HttpController.previewCsv @req, @res


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
