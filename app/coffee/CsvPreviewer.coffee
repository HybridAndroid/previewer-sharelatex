FilestoreHandler = require './FilestoreHandler'
Errors = require './Errors'
CsvSniffer = require('csv-sniffer')()
fs = require 'fs'


module.exports = CsvPreviewer =

	preview: (file_url, callback) ->
		callback(null, {})
