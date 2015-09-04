express = require('express')
fs = require('fs')


fixture_path = __dirname + '/../../../fixtures'

module.exports = FakeFileStore = () ->

		app = express()
		app.use '/file/:file_name', (req, res) ->
			file_name = req.params.file_name
			file_path = "#{fixture_path}/#{file_name}"
			stream = fs.createReadStream file_path
			stream.on 'error', (err) ->
				if err.code == 'ENOENT'
					return res.sendStatus 404
				res.sendStatus 500
			stream.pipe(res)

		return app
