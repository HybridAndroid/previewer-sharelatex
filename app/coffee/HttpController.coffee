logger = require "logger-sharelatex"
Errors = require "./Errors"
CsvPreviewer = require "./CsvPreviewer"

module.exports = HttpController =

	something: (req, res) ->
		logger.log "Something works"
		res.send 200

	previewCsv: (req, res) ->
		fileUrl = req.query.fileUrl
		logger.log fileUrl: fileUrl, "Generating preview for csv file"

		CsvPreviewer.preview fileUrl, (err, preview)->
			return next(err) if err?
			res.setHeader 'Content-Type', 'application/json'
			res.send HttpController._build_csv_preview(preview)

	_build_csv_preview: (preview) ->
		# Todo: project to the final preview format
		preview
