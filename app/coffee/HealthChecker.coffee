request = require 'request'
settings = require 'settings-sharelatex'

module.exports = HealthChecker =

	check: (callback) ->
		file_url = settings.previewer.health_check.file_url
		opts =
			uri: "http://localhost:#{settings.internal.previewer.port}/preview?fileUrl=#{file_url}&fileName=simple.csv"
			method: 'get'
			json: true
		request opts, (err, response, body) ->
			if err?
				return callback err
			if response.statusCode != 200
				return callback(new Error('recieved non-200 response from preview endpoint'))
			if body.type != 'csv' or typeof body.data != 'object'
				return callback(new Error('json data from preview endpoint malformed'))
			callback(null)
