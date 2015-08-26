Errors = require './Errors'
logger = require "logger-sharelatex"
fs = require 'fs'
npmCSVSniffer = require('csv-sniffer')()

_sniff_size_in_bytes = 400
_delimiters = [',', ';', '	']

module.exports = CsvSniffer =

	sniff: (file_path, callback) ->
		sniffer = new npmCSVSniffer(_delimiters)
		fs.open file_path, 'r', (err, fd) ->
			return callback(err, null) if err?
			buffer = new Buffer(_sniff_size_in_bytes)
			fs.read fd, buffer, 0, _sniff_size_in_bytes, 0, (err, bytes_read, data) ->
				return callback(err, null) if err?
				csv_details = sniffer.sniff(data.toString())
				callback(null, csv_details)
