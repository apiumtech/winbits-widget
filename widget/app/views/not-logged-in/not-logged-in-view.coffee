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
    @delegate 'click', '#wbi-login-btn', @onLoginButtonClick
    @delegate 'click', '#wbi-register-link', @onRegisterLinkClick

  attach: ->
    super
    console.log 'not-logged-in-view#attach'

  onLoginButtonClick: ->
    utils.redirectTo controller: 'login', action: 'index'

  onRegisterLinkClick: ->
    utils.redirectTo controller: 'register', action: 'index'
