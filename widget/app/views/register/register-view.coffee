View = require 'views/base/view'
utils = require 'lib/utils'
config = require 'config'

module.exports = class ModalRegisterView extends View
  container: 'header'
  id: 'wbi-register-modal'
  className: 'wbc-hide'
  template: require './templates/register'

  initialize: ->
    super
    @delegate 'click', '#wbi-login-link', -> utils.redirectTo controller: 'login', action: 'index'

  attach: ->
    super
    Winbits.$('<a>').wbfancybox(href: '#wbi-register-modal', onClosed: -> utils.redirectToNotLoggedInHome()).click()
    @$('#wbi-register-form').validate
      rules:
        'register-email':
          required: true
          email: true
        'register-password':
          required: true
        'register-again-password':
          required:true
          equalTo: true

