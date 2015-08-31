logger = require "logger-sharelatex"
FilestoreHandler = require './FilestoreHandler'
Errors = require './Errors'
CsvSniffer = require './CsvSniffer'
fs = require 'fs'


module.exports = CsvPreviewer =

	preview: (file_url, callback) ->
		FilestoreHandler.getSample file_url, (err, sample) ->
			if err?
				callback(err, null)
			else
				CsvSniffer.sniff sample, (err, result) ->
					if err?
						callback(err, null)
					else
						callback(null, result)
