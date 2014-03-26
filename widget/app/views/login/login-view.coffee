View = require 'views/base/view'
utils = require 'lib/utils'
config = require 'config'

module.exports = class ModalLoginPageView extends View
  container: 'header'
  id: 'wbi-login-modal'
  className: 'wbc-hide'
  autoRender: true
  template: require './templates/login'
  autoAttach: true

  initialize: ->
    super

  attach: ->
    super
    Winbits.$('<a>').fancybox(padding: 0, href: '#loginForm', onClosed: -> utils.redirectToNotLoggedInHome()).click()
