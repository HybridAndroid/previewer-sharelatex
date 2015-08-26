FilestoreHandler = require './FilestoreHandler'
Errors = require './Errors'
CsvSniffer = require('csv-sniffer')()
fs = require 'fs'


module.exports = CsvPreviewer =

	preview: (file_url, callback) ->
		callback(null, {})

	sniff: (file_path, callback) ->
		sniff_size_in_bytes = 1000
		sniffer = new CsvSniffer()
		fs.open file_path, 'r', (err, fd) ->
			callback(err, null) if err?
			fs.read fd, new Buffer(sniff_size_in_bytes), 0, sniff_size_in_bytes, 0, (err, bytes_read, data) ->
				callback(err, null) if err?
				csv_details = sniffer.sniff(data.toString())
				callback(null, csv_details)
