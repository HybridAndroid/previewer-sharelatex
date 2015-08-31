logger = require "logger-sharelatex"
Errors = require "./Errors"
FilestoreHandler = require './FilestoreHandler'
CsvSniffer = require './CsvSniffer'

module.exports = HttpController =

	something: (req, res) ->
		logger.log "Something works"
		res.send 200

	previewCsv: (req, res, next = (error) ->) ->
		file_url = req.query.fileUrl
		# fixture for debugging
		# file_url = 'http://localhost:3009/project/55dc2645c75625e45a722907/file/55deec7f3def1dd5f3c31558'
		logger.log file_url: file_url, "Generating preview for csv file"

		FilestoreHandler.getSample file_url, (err, sample) ->
			return next(err) if err?
			CsvSniffer.sniff sample, (err, result) ->
				return next(err) if err?
				res.json HttpController._build_csv_preview(result)

	_build_csv_preview: (preview) ->
		# Todo: project to the final preview format
		preview
