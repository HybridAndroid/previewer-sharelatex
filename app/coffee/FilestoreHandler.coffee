logger = require("logger-sharelatex")
fs = require("fs")
request = require("request")
settings = require("settings-sharelatex")

oneMinInMs = 60 * 1000
fiveMinsInMs = oneMinInMs * 5

module.exports = FileStoreHandler =

	getFileStream: (fileUrl, callback) ->
		opts =
			method: 'get'
			uri: fileUrl
			timeout: fiveMinsInMs
		readStream = request(opts)
		callback(null, readStream)
