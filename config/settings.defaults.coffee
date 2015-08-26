http = require('http')
http.globalAgent.maxSockets = 300

module.exports =
	internal:
		previewer:
			port: 3021
			host: "localhost"

	mongo:
		url: 'mongodb://127.0.0.1/sharelatex'

	#previewer:
	#	s3:
	#		key: ""
	#		secret: ""
	#		bucket: "something"
