SandboxedModule = require('sandboxed-module')
assert = require("chai").assert
sinon = require('sinon')
chai = require('chai')
chai.should()
expect = chai.expect
modulePath = require('path').join __dirname, '../../../app/js/CsvSniffer'

fixture_path = '../../fixtures/'


describe "CsvSniffer", ->

	it "should pass", (done) ->
		1.should.equal 1
		done()
