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
			"request": @request = sinon.stub()
		@response =
			statusCode: 200

	describe "getSample", ->

		it "should include range header in request to filestore", (done) ->
			@request.callsArgWith(1, null, @response, "wat")
			@FilestoreHandler.getSample @uri, (err, data) =>
				expect(@request.lastCall.args[0].headers.Range).to.equal "bytes=0-#{1024 * 16}"
				done()

		it "should produce an error if the request errors", (done) ->
			@request.callsArgWith(1, new Error('woops'), @response, "")
			@FilestoreHandler.getSample @uri, (err, data) ->
				expect(data).to.equal null
				expect(err).to.not.equal null
				done()
