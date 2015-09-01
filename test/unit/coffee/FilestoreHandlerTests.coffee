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
			@FilestoreHandler.getSample @uri, (err, data) =>
				expect(@request.lastCall.args[0].method).to.equal 'get'
				done()

		it "should include range header in request to filestore", (done) ->
			@FilestoreHandler.getSample @uri, (err, data) =>
				expect(@request.lastCall.args[0].headers.Range).to.equal "bytes=0-#{1024 * 16}"
				done()

		# Error conditions
		it "should produce an error if the response status is not 200", (done) ->
			@response.statusCode = 500
			@request.callsArgWith(1, null, @response, @body)
			@FilestoreHandler.getSample @uri, (err, data) ->
				expect(data).to.equal null
				expect(err).to.not.equal null
				done()

		it "should produce a NotFoundError when the response code is 404", (done) ->
			@response.statusCode = 404
			@request.callsArgWith(1, null, @response, @body)
			@FilestoreHandler.getSample @uri, (err, data) =>
				expect(err).to.not.equal null
				expect(err instanceof @Errors.NotFoundError).to.equal true
				done()

		it "should produce an error if the request errors", (done) ->
			@request.callsArgWith(1, new Error('woops'), @response, @body)
			@FilestoreHandler.getSample @uri, (err, data) ->
				expect(data).to.equal null
				expect(err).to.not.equal null
				done()
