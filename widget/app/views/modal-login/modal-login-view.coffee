View = require 'views/base/view'
util = require 'lib/util'
config = require 'config'

module.exports = class ModalLoginPageView extends View
  container: 'header'
  id: 'wbi-login-modal'
  className: 'ui-helper-hidden'
  autoRender: true
  template: require './templates/modal-login'
  autoAttach: true

  initialize: ->
    super

  attach: ->
    super
    Winbits.$('<a>').fancybox(padding: 0, href: '#loginForm', onClosed: -> window.location.hash = '#').click()
