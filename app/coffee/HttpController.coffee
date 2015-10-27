logger = require "logger-sharelatex"
Errors = require "./Errors"
FilestoreHandler = require './FilestoreHandler'
CsvSniffer = require './CsvSniffer'
HealthChecker = require './HealthChecker'
metrics = require 'metrics-sharelatex'
Path = require 'path'
isBinaryFile = require 'isbinaryfile'

module.exports = HttpController =

	_get_preview_type: (file_name, sample) ->
		extension = Path.extname(file_name)
		if extension == '.csv'
			return 'csv'
		if extension == '.txt'
			return 'text'
		else
			bytes = new Buffer(sample.data)
			is_binary = isBinaryFile.sync(bytes, bytes.length)
			if is_binary == true
				return 'binary'
			else
				return 'text'

	preview: (req, res, next = (error) ->) ->
		file_url = req.query.fileUrl
		file_name = req.query.fileName
		if !file_url?
			logger.log "no fileUrl query parameter supplied"
			return res.status(400).send("required query param 'fileUrl' missing")
		if !file_name?
			logger.log "no fileName query parameter supplied"
			return res.status(400).send("required query param 'fileName' missing")
		logger.log file_url: file_url, file_name: file_name, "Generating smart preview for file"
		metrics.inc "getPreview"
		FilestoreHandler.getSample file_url, (err, sample) ->
			if err?
				if err instanceof Errors.NotFoundError
					return res.sendStatus 404
				else
					return next(err)

			res.setHeader "Content-Type", "application/json"
			preview_type = HttpController._get_preview_type file_name, sample
			preview =
				source: file_url
				filename: file_name
				type: preview_type
				data: null
				truncated: sample.truncated
			if preview_type == 'binary'
				preview.data = null
				return res.status(200).send(preview)
			if preview_type == 'text'
				preview.data = sample.data
				return res.status(200).send(preview)
			if preview_type == 'csv'
				logger.log file_url: file_url, 'sniffing csv sample'
				return CsvSniffer.sniff sample.data, (err, csv_details) ->
					if err?
						logger.log file_url: file_url, error_message: err.message, "failed to sniff csv sample"
						return next(err)
					preview.data =
						rows: csv_details.records,
						labels: csv_details.labels
					res.status(200).send(preview)

	# legacy endpoints
	previewText: (req, res, next = (error) ->) ->
		file_url = req.query.fileUrl
		if !file_url?
			logger.log "no fileUrl query parameter supplied"
			return res.status(400).send("required query param 'fileUrl' missing")
		logger.log file_url: file_url, "Generating preview for file"
		metrics.inc "getPreview"
		FilestoreHandler.getSample file_url, (err, sample) ->
			if err?
				if err instanceof Errors.NotFoundError
					return res.sendStatus 404
				else
					return next(err)
			logger.log file_url: file_url, 'sending preview to client'
			res.setHeader "Content-Type", "application/json"
			res.status(200).send({source: file_url, data: sample.data, truncated: sample.truncated})

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
					return res.sendStatus 404
				else
					return next(err)
			logger.log file_url: file_url, 'sniffing csv sample'
			CsvSniffer.sniff sample.data, (err, csv_details) ->
				if err?
					logger.log file_url: file_url, error_message: err.message, "failed to sniff csv sample"
					return next(err)
				res.setHeader "Content-Type", "application/json"
				res.status(200).send(HttpController._build_csv_preview(file_url, csv_details, sample.truncated))

	_build_csv_preview: (file_url, csv_details, truncated) ->
		source: file_url,
		rows: csv_details.records,
		delimiter: csv_details.delimiter,
		quoteChar: csv_details.quoteChar,
		newlineStr: csv_details.newlineStr,
		types: csv_details.types,
		labels: csv_details.labels
		truncated: truncated

	health_check: (req, res, next = (error) ->) ->
		HealthChecker.check (err) ->
			if err?
				return res.status(500).send()
			res.status(200).send('OK')
