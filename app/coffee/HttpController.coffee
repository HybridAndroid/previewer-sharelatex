logger = require "logger-sharelatex"
Errors = require "./Errors"
FilestoreHandler = require './FilestoreHandler'
CsvSniffer = require './CsvSniffer'

module.exports = HttpController =

	previewCsv: (req, res, next = (error) ->) ->
		file_url = req.query.fileUrl
		# fixture for debugging
		# file_url = 'http://localhost:3009/project/55dc2645c75625e45a722907/file/55deec7f3def1dd5f3c31558'
		if !file_url?
			logger.log "no fileUrl query parameter supplied"
			return res.send 400, "required query param 'fileUrl' missing"
		logger.log file_url: file_url, "Generating preview for csv file"
		FilestoreHandler.getSample file_url, (err, sample) ->
			return next(err) if err?
			CsvSniffer.sniff sample, (err, csv_details) ->
				return next(err) if err?
				res.send 200, HttpController._build_csv_preview(file_url, csv_details)

	_build_csv_preview: (file_url, csv_details) ->
		# Todo: project to the final csv_details format
		source: file_url,
		rows: csv_details.records,
		delimiter: csv_details.delimiter,
		quoteChar: csv_details.quoteChar,
		newlineStr: csv_details.newlineStr,
		types: csv_details.types,
		labels: csv_details.labels
