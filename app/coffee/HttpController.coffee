logger = require "logger-sharelatex"
Errors = require "./Errors"
FilestoreHandler = require './FilestoreHandler'
CsvSniffer = require './CsvSniffer'
metrics = require 'metrics-sharelatex'

module.exports = HttpController =

	previewCsv: (req, res, next = (error) ->) ->
		file_url = req.query.fileUrl
		if !file_url?
			logger.log "no fileUrl query parameter supplied"
			return res.status(400).send("required query param 'fileUrl' missing")
		logger.log file_url: file_url, "Generating preview for csv file"
		metrics.inc "getPreviewCsv"
		FilestoreHandler.getSample file_url, (err, sample) ->
			if err?
				if err instanceof Errors.NotFoundError
					return res.send 404
				else
					return next(err)
			logger.log file_url: file_url, 'sniffing csv sample'
			CsvSniffer.sniff sample, (err, csv_details) ->
				if err?
					logger.log file_url: file_url, error_message: error.message, "failed to sniff csv sample"
					return next(err)
				res.status(200).send(HttpController._build_csv_preview(file_url, csv_details))

	_build_csv_preview: (file_url, csv_details) ->
		# Todo: project to the final csv_details format
		source: file_url,
		rows: csv_details.records,
		delimiter: csv_details.delimiter,
		quoteChar: csv_details.quoteChar,
		newlineStr: csv_details.newlineStr,
		types: csv_details.types,
		labels: csv_details.labels
