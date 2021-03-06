SandboxedModule = require('sandboxed-module')
assert = require("chai").assert
sinon = require('sinon')
chai = require('chai')
chai.should()
expect = chai.expect
modulePath = require('path').join __dirname, '../../../app/js/FilestoreHandler'

fixture_path = __dirname+'/../../fixtures/'


describe "FilestoreHandler", ->

	beforeEach ->
		@uri = "somewhere"
		@FilestoreHandler = SandboxedModule.require modulePath, requires:
			"logger-sharelatex": @logger = { log: sinon.stub(), setHeader: sinon.stub() }
			"./Errors": @Errors =
				FileStoreError: sinon.stub()
				NotFoundError: sinon.stub()
			"request": @request = sinon.stub()
		@response =
			statusCode: 200
		@body = 'some response body'

	describe "getSample", ->

		beforeEach ->
			@request.callsArgWith(1, null, @response, @body)

		it "should issue a get request", (done) ->
			@FilestoreHandler.getSample @uri, (err, sample) =>
				expect(@request.lastCall.args[0].method).to.equal 'get'
				done()

		it "should produce a sample object", (done) ->
			@FilestoreHandler.getSample @uri, (err, sample) =>
				expect(sample).to.not.equal null
				expect(sample).to.include.keys 'data', 'truncated'
				expect(sample.data).to.equal @body
				expect(sample.truncated).to.equal false
				done()

		describe "with a very large response body", (done) ->
			beforeEach ->
				@body = ('Z' for i in [1..(16 * 1024)]).join('') # 16k of 'ZZZZZZZZ...'
				@request.callsArgWith(1, null, @response, @body)

			it "should be truncated", (done) ->
				@FilestoreHandler.getSample @uri, (err, sample) =>
					expect(sample.data).to.equal @body
					expect(sample.truncated).to.equal true
					done()

		it "should include range header in request to filestore", (done) ->
			@FilestoreHandler.getSample @uri, (err, sample) =>
				expect(@request.lastCall.args[0].headers.Range).to.equal "bytes=0-#{(1024 * 16) - 1}"
				done()

		# Error conditions
		it "should produce an error if the response status is not 200", (done) ->
			@response.statusCode = 500
			@request.callsArgWith(1, null, @response, @body)
			@FilestoreHandler.getSample @uri, (err, sample) ->
				expect(sample).to.equal null
				expect(err).to.not.equal null
				done()

		it "should produce a NotFoundError when the response code is 404", (done) ->
			@response.statusCode = 404
			@request.callsArgWith(1, null, @response, @body)
			@FilestoreHandler.getSample @uri, (err, sample) =>
				expect(err).to.not.equal null
				expect(err instanceof @Errors.NotFoundError).to.equal true
				done()

		it "should produce an error if the request errors", (done) ->
			@request.callsArgWith(1, new Error('woops'), @response, @body)
			@FilestoreHandler.getSample @uri, (err, sample) ->
				expect(sample).to.equal null
				expect(err).to.not.equal null
				done()
