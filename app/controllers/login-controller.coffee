HomeController = require 'controllers/home-controller'
ModalLoginView = require 'views/modal-login/modal-login-view'
util = require 'lib/util'

module.exports = class LoginController extends HomeController
  
  showLogin: ->
   @view = new ModalLoginView()



