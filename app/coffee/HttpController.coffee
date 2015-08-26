logger = require "logger-sharelatex"
Errors = require "./Errors"

module.exports = HttpController =

	something: (req, res) ->
		logger.log "Something works"
		res.send 200

	previewCsv: (req, res) ->
		fileUrl = req.query.fileUrl
		logger.log fileUrl: fileUrl, "Generating preview for csv file"

		res.send 200
