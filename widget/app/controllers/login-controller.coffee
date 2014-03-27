NotLoggedInController = require 'controllers/not-logged-in-controller'
LoginView = require 'views/login/login-view'
utils = require 'lib/utils'

module.exports = class LoginController extends NotLoggedInController

  index: ->
    console.log 'login#index'
    @view = new LoginView()
