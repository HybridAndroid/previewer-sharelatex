Errors = require './Errors'
CsvSniffer = require('csv-sniffer')()
fs = require 'fs'

_sniff_size_in_bytes = 1000

module.exports = CsvSniffer =

	sniff: (file_path, callback) ->
		sniffer = new CsvSniffer()
		fs.open file_path, 'r', (err, fd) ->
			callback(err, null) if err?
			fs.read fd, new Buffer(_sniff_size_in_bytes), 0, _sniff_size_in_bytes, 0, (err, bytes_read, data) ->
				callback(err, null) if err?
				csv_details = sniffer.sniff(data.toString())
				callback(null, csv_details)
