View = require 'views/base/view'
utils = require 'lib/utils'
config = require 'config'

module.exports = class ModalLoginPageView extends View
  container: 'header'
  id: 'wbi-login-modal'
  className: 'wbc-hide'
  template: require './templates/login'

  initialize: ->
    super

  attach: ->
    super
    Winbits.$('<a>').wbfancybox(href: '#loginForm', onClosed: -> utils.redirectToNotLoggedInHome()).click()
