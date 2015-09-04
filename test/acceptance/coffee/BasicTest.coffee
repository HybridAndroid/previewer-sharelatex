assert = require("chai").assert
sinon = require('sinon')
chai = require('chai')
should = chai.should()
expect = chai.expect
SandboxedModule = require('sandboxed-module')
request = require("request")
settings = require("settings-sharelatex")
express = require('express')
Router = require('../../../app/js/Router')


describe "Previewer", ->

	before (done)->
		# @requires =
		# 	"metrics-sharelatex": @metrics =
		# 		inc: ->
		# 	"settings-sharelatex": @settings = {}
		# 	"logger-sharelatex": @logger = { log: sinon.stub(), setHeader: sinon.stub() }
		# 	"metrics-sharelatex":
		# 		inc: sinon.stub()
		@previewer_host = 'localhost'
		@previewer_port = 9091
		@app = express()
		@app.name = 'test_previewer'
		Router(@app)
		@server = @app.listen @previewer_port, @previewer_host, (err) ->
			throw err if err?
			console.log ">> test previewer started on #{previewer_host}/#{previewer_port}"
		done()

	after (done) ->
		@server.close()
		done()

	it "should something", (done)->
		expect(1).to.equal 1
		done()

	it "should respond to status endpoint", (done) ->
		opts = {
			uri: "http://#{@previewer_host}:#{@previewer_port}/status"
			method: 'get'
		}
		console.log opts
		request opts, (err, response, body) =>
			expect(response.statusCode).to.equal 200
			expect(body).to.equal "#{@app.name} is alive"
			done()
