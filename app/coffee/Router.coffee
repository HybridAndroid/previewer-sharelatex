HttpController = require "./HttpController"

module.exports = Router = (app) ->

	app.get '/status', (req, res) ->
		res.send("#{app.locals.app_name} is alive")

	app.get '/health_check', HttpController.health_check

	app.get '/preview/csv', HttpController.previewCsv

	app.get '/preview/text', HttpController.previewText

	app.get '/preview', HttpController.preview
