logger = require "logger-sharelatex"
Errors = require "./Errors"
CsvPreviewer = require "./CsvPreviewer"

module.exports = HttpController =

	something: (req, res) ->
		logger.log "Something works"
		res.send 200

	previewCsv: (req, res) ->
		fileUrl = req.query.fileUrl
		# fixture for debugging
		fileUrl = 'http://localhost:3009/project/55dc2645c75625e45a722907/file/55deec7f3def1dd5f3c31558'
		logger.log fileUrl: fileUrl, "Generating preview for csv file"

		CsvPreviewer.preview fileUrl, (err, preview)->
			return next(err) if err?
			res.setHeader 'Content-Type', 'application/json'
			res.send HttpController._build_csv_preview(preview)

	_build_csv_preview: (preview) ->
		# Todo: project to the final preview format
		preview
