Controller = require 'controllers/base/controller'
ModalLoginView = require 'views/modal-login/modal-login-view'
util = require 'lib/util'

module.exports = class LoginController extends Controller

  showLogin: ->
    console.log 'login#showLogin'
    @view = new ModalLoginView()
