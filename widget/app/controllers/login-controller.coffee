NotLoggedInController = require 'controllers/not-logged-in-controller'
LoginView = require 'views/login/login-view'
util = require 'lib/util'

module.exports = class LoginController extends NotLoggedInController

  index: ->
    console.log 'login#index'
    @view = new LoginView()
