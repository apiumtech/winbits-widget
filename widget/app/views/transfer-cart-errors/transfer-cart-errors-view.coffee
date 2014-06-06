'use strict'

View = require 'views/base/view'
utils = require 'lib/utils'
mediator = Winbits.Chaplin.mediator
$ = Winbits.$
_ = Winbits._
env = Winbits.env

module.exports = class LoginView extends View
  container: '#wbi-winbits-modals'
  id: 'wbi-login-modal'
  template: require './templates/transfer-cart-errors'

  initialize: ->
    super
#    @delegate 'click', '#wbi-login-in-btn', @doLogin
#    @delegate 'click', '#wbi-login-facebook-link', @doFacebookLogin

  attach: ->
    super
    @showAsModal()
#    @$('.contentModal').customCheckbox();
#    @$('form#wbi-login-form').validate
#      rules:
#        email:
#          required: true
#          email: true
#        password:
#          required: true
#          minlength: 6
#
  showAsModal: ->
    $('<a>').wbfancybox(href: '#' + @id, onClosed: (-> utils.redirectTo(controller: 'home', action: 'index', params: 'xxxxxx')), height:550).click()