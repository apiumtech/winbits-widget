NotLoggedInController = require 'controllers/not-logged-in-controller'
LoginView = require 'views/login/login-view'
Login = require 'models/login/login'
utils = require 'lib/utils'

module.exports = class LoginController extends NotLoggedInController

  index: ->
    console.log 'login#index'
    @model = new Login
    @view = new LoginView model: @model
