View = require 'views/base/view'
utils = require 'lib/utils'

module.exports = class NotLoggedInPageView extends View
  container: '#wbi-header-wrapper'
  className: 'miCuenta login'
  autoRender: true
  template: require './templates/not-logged-in'
  autoAttach: true

  initialize: ->
    super
    @delegate 'click', '#wbi-login-btn', -> utils.redirectTo controller: 'login', action: 'index'
    @delegate 'click', '#wbi-register-link', -> utils.redirectTo controller: 'register', action: 'index'

  attach: ->
    super
