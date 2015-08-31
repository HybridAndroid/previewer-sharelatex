logger = require("logger-sharelatex")
request = require("request")
FileStoreError = require('./Errors').FileStoreError

oneMinInMs = 60 * 1000
fiveMinsInMs = oneMinInMs * 5

max_bytes = 1024 * 16 # 16k

module.exports = FileStoreHandler =

	getSample: (fileUrl, callback) ->
		opts =
			method: 'get'
			uri: fileUrl
			timeout: fiveMinsInMs
			headers: {'Range': "bytes=0-#{max_bytes}"}
		logger.log options: opts, "getting sample of file from filestore"
		request opts, (err, response, body) ->
			if err?
				callback err, null
			else if response.statusCode != 200
				err = new FileStoreError("Unexpected response code from filestore: #{response.statusCode}")
				callback(err, body)
			else
				callback null, body
