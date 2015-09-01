logger = require("logger-sharelatex")
request = require("request")
Errors = require('./Errors')

oneMinInMs = 60 * 1000
fiveMinsInMs = oneMinInMs * 5

max_bytes = 1024 * 16 # 16k

module.exports = FileStoreHandler =

	getSample: (file_url, callback) ->
		opts =
			method: 'get'
			uri: file_url
			timeout: fiveMinsInMs
			headers: {'Range': "bytes=0-#{max_bytes}"}
		logger.log options: opts, "getting sample of file from filestore"
		request opts, (err, response, body) ->
			if err?
				logger.log file_url: file_url, "error getting sample from filestore"
				callback err, null
			else if response.statusCode == 404
				logger.log file_url: file_url, "filestore could not find file"
				err = new Errors.NotFoundError()
				callback(err, null)
			else if response.statusCode != 200
				logger.log file_url: file_url, code: response.statusCode, "filestore responded with non-ok status"
				err = new FileStoreError("Unexpected response code from filestore: #{response.statusCode}")
				callback(err, null)
			else
				logger.log file_url: file_url, "got sample from filestore"
				callback null, body
