HttpController = require "./HttpController"

module.exports = Router = (app) ->

	app.get '/status', (req, res)->
		res.send("#{app.name} is alive")

	app.get '/preview/csv', HttpController.previewCsv
