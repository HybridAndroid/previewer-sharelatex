SnifferError = require('./Errors').SnifferError
logger = require "logger-sharelatex"
CSVSniffer = require('csv-sniffer')()

_delimiters = [',', ';', '	']

module.exports = CsvSniffer =

	sniff: (sample, callback) ->
		try
			logger.log 'sniffing csv sample'
			sniffer = new CSVSniffer(_delimiters)
			csv_details = sniffer.sniff(sample)
			callback(null, csv_details)
		catch error
			logger.log "failed to sniff csv sample: #{error.message}"
			err = new SnifferError("Failed to sniff csv sample: #{error.message}")
			callback(err, null)
