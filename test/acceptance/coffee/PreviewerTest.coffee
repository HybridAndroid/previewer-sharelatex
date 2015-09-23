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
FakeFileStore = require('./helpers/FakeFileStore')

describe "Previewer", ->

	before (done)->

		# start a fake FileStore service
		@filestore_host = 'localhost'
		@filestore_port = 9092
		@filestore_app = FakeFileStore()
		@filestore_server = @filestore_app.listen @filestore_port, @filestore_host, (err) =>
			throw err if err?
			console.log ">> test filestore started on #{@filestore_host}:#{@filestore_port}"

		# set up a Previewer test app
		@previewer_host = 'localhost'
		@previewer_port = 9091
		@previewer_app = express()
		@previewer_app.locals.app_name = 'test_previewer'
		Router(@previewer_app)
		@previewer_server = @previewer_app.listen @previewer_port, @previewer_host, (err) =>
			throw err if err?
			console.log ">> test previewer started on #{@previewer_host}:#{@previewer_port}"
		@filestore_url = "http://#{@filestore_host}:#{@filestore_port}"
		@previewer_url = "http://#{@previewer_host}:#{@previewer_port}"
		done()

	after (done) ->
		# shut down both express apps
		@previewer_server.close()
		@filestore_server.close()
		done()

	describe "/status", ->

		it "should respond to status endpoint", (done) ->
			opts = {
				uri: "#{@previewer_url}/status"
				method: 'get'
			}
			request opts, (err, response, body) =>
				expect(response.statusCode).to.equal 200
				expect(body).to.equal "#{@previewer_app.locals.app_name} is alive"
				expect(body).to.not.equal " is alive"
				done()

	describe "/preview", ->

		describe "with a good csv file", (done) ->

			beforeEach ->
				@file_name = 'simple.csv'
				@file_url = "#{@filestore_url}/file/#{@file_name}"
				@opts =
					uri: "#{@previewer_url}/preview?fileUrl=#{@file_url}&fileName=#{@file_name}"
					method: 'get'
					json: true

			it "should produce a 200 response", (done) ->
				request @opts, (err, response, body) =>
					expect(err).to.equal null
					response.statusCode.should.equal 200
					done()

			it "should have a source attribute", (done) ->
				request @opts, (err, response, body) =>
					expect(body).to.include.keys 'source'
					expect(body.source).to.equal @file_url
					done()

			it "should have a filename attribute", (done) ->
				request @opts, (err, response, body) =>
					expect(body.filename).to.equal @file_name
					done()

			it "should have type 'csv'", (done) ->
				request @opts, (err, response, body) =>
					expect(body).to.include.keys 'type'
					expect(body.type).to.equal 'csv'
					done()

			it "should have a truncated attribute", (done) ->
				request @opts, (err, response, body) =>
					expect(body).to.include.keys 'truncated'
					expect(body.truncated).to.equal false
					done()

			it "should have a data attribute", (done) ->
				request @opts, (err, response, body) =>
					expect(body).to.include.keys 'data'
					done()

			it "should have an array of rows", (done) ->
				request @opts, (err, response, body) =>
					expect(body.data.rows).to.be.Array
					expect(body.data.rows.length).to.equal 7
					body.data.rows.forEach (row) ->
						expect(row.length).to.equal 12
					done()

			it "should have an array of labels", (done) ->
				request @opts, (err, response, body) =>
					expect(body.data.labels).to.be.Array
					expect(body.data.labels.length).to.equal 12
					done()

		describe "with a quoted csv file", (done) ->

			beforeEach ->
				@file_name = 'simple_quoted.csv'
				@file_url = "#{@filestore_url}/file/#{@file_name}"
				@opts =
					uri: "#{@previewer_url}/preview?fileUrl=#{@file_url}&fileName=#{@file_name}"
					method: 'get'
					json: true

			it "should produce a 200 response", (done) ->
				request @opts, (err, response, body) =>
					expect(err).to.equal null
					response.statusCode.should.equal 200
					done()

			it "should have a filename attribute", (done) ->
				request @opts, (err, response, body) =>
					expect(body.filename).to.equal @file_name
					done()

			it "should have an array of rows", (done) ->
				request @opts, (err, response, body) =>
					expect(body.data.rows).to.be.Array
					expect(body.data.rows.length).to.equal 4
					body.data.rows.forEach (row) ->
						expect(row.length).to.equal 12
					done()

			it "should have type 'csv'", (done) ->
				request @opts, (err, response, body) =>
					expect(body).to.include.keys 'type'
					expect(body.type).to.equal 'csv'
					done()

			it "should have an array of labels", (done) ->
				request @opts, (err, response, body) =>
					expect(body.data.labels).to.be.Array
					expect(body.data.labels.length).to.equal 12
					done()

			it "should have a truncated attribute", (done) ->
				request @opts, (err, response, body) =>
					expect(body).to.include.keys 'truncated'
					expect(body.truncated).to.equal false
					done()

		describe "with a binary file", ->

			beforeEach ->
				@file_name = 'hello-world-in-python'
				@file_url = "#{@filestore_url}/file/#{@file_name}"
				@opts =
					uri: "#{@previewer_url}/preview?fileUrl=#{@file_url}&fileName=#{@file_name}"
					method: 'get'
					json: true

			it "should produce a 200 response", (done) ->
				request @opts, (err, response, body) =>
					expect(err).to.equal null
					response.statusCode.should.equal 200
					done()

			it "should have a filename attribute", (done) ->
				request @opts, (err, response, body) =>
					expect(body.filename).to.equal @file_name
					done()

			it "should have type 'binary'", (done) ->
				request @opts, (err, response, body) =>
					expect(body).to.include.keys 'type'
					expect(body.type).to.equal 'binary'
					done()

			it "should have a null data property", (done) ->
				request @opts, (err, response, body) =>
					expect(body).to.include.keys 'data'
					expect(body.data).to.equal null
					done()

			it "should have a truncated attribute", (done) ->
				request @opts, (err, response, body) =>
					expect(body).to.include.keys 'truncated'
					expect(body.truncated).to.equal false
					done()

		describe "with a .txt file", ->

			beforeEach ->
				@file_name = 'prose.txt'
				@file_url = "#{@filestore_url}/file/#{@file_name}"
				@opts =
					uri: "#{@previewer_url}/preview?fileUrl=#{@file_url}&fileName=#{@file_name}"
					method: 'get'
					json: true

			it "should produce a 200 response", (done) ->
				request @opts, (err, response, body) =>
					expect(err).to.equal null
					response.statusCode.should.equal 200
					done()

			it "should have a filename attribute", (done) ->
				request @opts, (err, response, body) =>
					expect(body.filename).to.equal @file_name
					done()

			it "should have type 'text'", (done) ->
				request @opts, (err, response, body) =>
					expect(body).to.include.keys 'type'
					expect(body.type).to.equal 'text'
					done()

			it "should have a text data property", (done) ->
				request @opts, (err, response, body) =>
					expect(body).to.include.keys 'data'
					expect(body.data).to.be.String
					expect(body.data.slice(0, 8)).to.equal 'hey this'
					done()

			it "should have a truncated attribute", (done) ->
				request @opts, (err, response, body) =>
					expect(body).to.include.keys 'truncated'
					expect(body.truncated).to.equal false
					done()

		describe "with a .log file", ->

			beforeEach ->
				@file_name = 'some.log'
				@file_url = "#{@filestore_url}/file/#{@file_name}"
				@opts =
					uri: "#{@previewer_url}/preview?fileUrl=#{@file_url}&fileName=#{@file_name}"
					method: 'get'
					json: true

			it "should produce a 200 response", (done) ->
				request @opts, (err, response, body) =>
					expect(err).to.equal null
					response.statusCode.should.equal 200
					done()

			it "should have a filename attribute", (done) ->
				request @opts, (err, response, body) =>
					expect(body.filename).to.equal @file_name
					done()

			it "should have type 'text'", (done) ->
				request @opts, (err, response, body) =>
					expect(body).to.include.keys 'type'
					expect(body.type).to.equal 'text'
					done()

			it "should have a text data property", (done) ->
				request @opts, (err, response, body) =>
					expect(body).to.include.keys 'data'
					expect(body.data).to.be.String
					expect(body.data.slice(0, 8)).to.equal '2015-08-'
					done()

			it "should have a truncated attribute", (done) ->
				request @opts, (err, response, body) =>
					expect(body).to.include.keys 'truncated'
					expect(body.truncated).to.equal false
					done()

		describe "with an extension-less text file", ->

			beforeEach ->
				@file_name = 'prose'
				@file_url = "#{@filestore_url}/file/#{@file_name}"
				@opts =
					uri: "#{@previewer_url}/preview?fileUrl=#{@file_url}&fileName=#{@file_name}"
					method: 'get'
					json: true

			it "should produce a 200 response", (done) ->
				request @opts, (err, response, body) =>
					expect(err).to.equal null
					response.statusCode.should.equal 200
					done()

			it "should have a filename attribute", (done) ->
				request @opts, (err, response, body) =>
					expect(body.filename).to.equal @file_name
					done()

			it "should have type 'text'", (done) ->
				request @opts, (err, response, body) =>
					expect(body).to.include.keys 'type'
					expect(body.type).to.equal 'text'
					done()

			it "should have a text data property", (done) ->
				request @opts, (err, response, body) =>
					expect(body).to.include.keys 'data'
					expect(body.data).to.be.String
					expect(body.data.slice(0, 8)).to.equal 'hey this'
					done()

			it "should have a truncated attribute", (done) ->
				request @opts, (err, response, body) =>
					expect(body).to.include.keys 'truncated'
					expect(body.truncated).to.equal false
					done()


		describe "with a non-existant file", ->

			it "should produce a 404", (done) ->
				@file_name = 'this_clearly_does_not_exist.csv'
				@file_url = "#{@filestore_url}/file/#{@file_name}"
				@opts = {
					uri: "#{@previewer_url}/preview?fileUrl=#{@file_url}&fileName=#{@file_name}"
					method: 'get'
				}
				request @opts, (err, response, body) =>
					expect(err).to.equal null
					response.statusCode.should.equal 404
					done()

		describe "without a fileUrl query param", ->

			it "should produce a 400 response", (done) ->
				@opts = {
					uri: "#{@previewer_url}/preview?wat=yes"
					method: 'get'
				}
				request @opts, (err, response, body) =>
					expect(err).to.equal null
					response.statusCode.should.equal 400
					done()

		describe "without a fileName query param", ->

			it "should produce a 400 response", (done) ->
				@opts = {
					uri: "#{@previewer_url}/preview?fileUrl=yes"
					method: 'get'
				}
				request @opts, (err, response, body) =>
					expect(err).to.equal null
					response.statusCode.should.equal 400
					done()

	# old csv endpoint
	describe "/preview/csv", ->

		describe "with a good csv file", (done) ->

			beforeEach ->
				@file_url = "#{@filestore_url}/file/simple.csv"
				@opts =
					uri: "#{@previewer_url}/preview/csv?fileUrl=#{@file_url}"
					method: 'get'
					json: true

			it "should produce a 200 response", (done) ->
				request @opts, (err, response, body) =>
					expect(err).to.equal null
					response.statusCode.should.equal 200
					done()

			it "should have a source attribute", (done) ->
				request @opts, (err, response, body) =>
					expect(body).to.include.keys 'source'
					expect(body.source).to.equal @file_url
					done()

			it "should have a truncated attribute", (done) ->
				request @opts, (err, response, body) =>
					expect(body).to.include.keys 'truncated'
					expect(body.truncated).to.equal false
					done()

			it "should have an array of rows", (done) ->
				request @opts, (err, response, body) =>
					expect(body.rows).to.be.Array
					expect(body.rows.length).to.equal 7
					body.rows.forEach (row) ->
						expect(row.length).to.equal 12
					done()

			it "should have an array of labels", (done) ->
				request @opts, (err, response, body) =>
					expect(body.labels).to.be.Array
					expect(body.labels.length).to.equal 12
					done()

			it "should have a null quoteChar property", (done) ->
				request @opts, (err, response, body) =>
					expect(body.quoteChar).to.equal null
					done()

			it "should have a delimiter property", (done) ->
				request @opts, (err, response, body) =>
					expect(body.delimiter).to.equal ','
					done()

		describe "with a quoted csv file", (done) ->

			beforeEach ->
				@file_url = "#{@filestore_url}/file/simple_quoted.csv"
				@opts =
					uri: "#{@previewer_url}/preview/csv?fileUrl=#{@file_url}"
					method: 'get'
					json: true

			it "should produce a 200 response", (done) ->
				request @opts, (err, response, body) =>
					expect(err).to.equal null
					response.statusCode.should.equal 200
					done()

			it "should have an array of rows", (done) ->
				request @opts, (err, response, body) =>
					expect(body.rows).to.be.Array
					expect(body.rows.length).to.equal 4
					body.rows.forEach (row) ->
						expect(row.length).to.equal 12
					done()

			it "should have an array of labels", (done) ->
				request @opts, (err, response, body) =>
					expect(body.labels).to.be.Array
					expect(body.labels.length).to.equal 12
					done()

			it "should have a quoteChar property", (done) ->
				request @opts, (err, response, body) =>
					expect(body.quoteChar).to.equal '"'
					done()

			it "should have a delimiter property", (done) ->
				request @opts, (err, response, body) =>
					expect(body.delimiter).to.equal ','
					done()

		describe "with a non-existant file", ->

			it "should produce a 404", (done) ->
				file_url = "#{@filestore_url}/file/this_clearly_does_not_exist.csv"
				opts = {
					uri: "#{@previewer_url}/preview/csv?fileUrl=#{file_url}"
					method: 'get'
				}
				request opts, (err, response, body) =>
					expect(err).to.equal null
					response.statusCode.should.equal 404
					done()

		describe "without a fileUrl query param", ->

			it "should produce a 400 response", (done) ->
				opts = {
					uri: "#{@previewer_url}/preview/csv?wat=yes"
					method: 'get'
				}
				request opts, (err, response, body) =>
					expect(err).to.equal null
					response.statusCode.should.equal 400
					done()
