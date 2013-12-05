View = require 'views/base/view'
config = require 'config'
util = require 'lib/util'
token = require 'lib/token'
mediator = require 'chaplin/mediator'
vendor = require 'lib/vendor'

module.exports = class AlreadyExistsUserView extends View
  autoRender: yes
  container: '#wbi-resend-confirmation-modal'
  template: require 'views/templates/widget/reset-password'

  initialize: ->
    super
    @delegate 'click', '#wbi-reset-form-login-btn', @onResendResetPasswordLinkClick
    @subscribeEvent 'alreadyexistuser', @onUserNotConfirmed

  attach: ->
    super
    @$el.find('.winbits-register-form').modal(show: false)


  onUserNotConfirmed: ->
    console.log("AFTER EVENT!!!!")



  onRensendConfirmationLinkClick: (e) ->
    e.preventDefault()
    @resendConfirmationMail()

  onResendResetPasswordLinkClick: () ->

  resendConfirmationMail: ->
    console.log("Send email password reset")