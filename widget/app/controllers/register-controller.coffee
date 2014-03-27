NotLoggedInController = require 'controllers/not-logged-in-controller'
RegisterView = require 'views/register/register-view'
util = require 'lib/util'

module.exports = class RegisterController extends NotLoggedInController

  index: ->
    console.log 'register#index'
    @view = new RegisterView()

