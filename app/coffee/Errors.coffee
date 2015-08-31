FileStoreError = (message) ->
	error = new Error(message)
	error.name = "FileStoreError"
	error.__proto__ = FileStoreError.prototype
	return error
FileStoreError.prototype.__proto__ = Error.prototype

SnifferError = (message) ->
	error = new Error(message)
	error.name = "SnifferError"
	error.__proto__ = SnifferError.prototype
	return error
SnifferError.prototype.__proto__ = Error.prototype

NotFoundError = (message) ->
	error = new Error(message)
	error.name = "NotFoundError"
	error.__proto__ = NotFoundError.prototype
	return error
NotFoundError.prototype.__proto__ = Error.prototype

module.exports = Errors =
	NotFoundError: NotFoundError
	SnifferError: SnifferError
	FileStoreError: FileStoreError
