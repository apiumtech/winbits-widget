View = require 'views/base/view'
utils = require 'lib/utils'

module.exports = class NotLoggedInPageView extends View
  container: '.mainHeader .wrapper'
  className: 'miCuenta login'
  autoRender: true
  template: require './templates/not-logged-in'
  autoAttach: true

  initialize: ->
    super
    @delegate 'click', '#wbi-login-btn', -> utils.redirectTo controller: 'login', action: 'index'

  attach: ->
    super
