View = require 'views/base/view'
utils = require 'lib/utils'
config = require 'config'
$ = Winbits.$

module.exports = class LoginView extends View
  container: 'header'
  id: 'wbi-login-modal'
  className: 'wbc-hide'
  template: require './templates/login'

  initialize: ->
    super

  attach: ->
    super
    @showAsModal()

  showAsModal: ->
    $('<a>').wbfancybox(href: '#loginForm', onClosed: -> utils.redirectToNotLoggedInHome()).click()
