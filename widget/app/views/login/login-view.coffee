'use strict'

View = require 'views/base/view'
utils = require 'lib/utils'
loginUtils = require 'lib/login-utils'
trackingUtils = require 'lib/tracking-utils'
mediator = Winbits.Chaplin.mediator
$ = Winbits.$
_ = Winbits._
env = Winbits.env

module.exports = class LoginView extends View
  container: '#wbi-winbits-modals'
  id: 'wbi-login-modal'
  template: require './templates/login'

  initialize: ->
    super
    @delegate 'click', '#wbi-login-in-btn', @doLogin
    @delegate 'click', '#wbi-facebook-link', @doFacebookLogin

  attach: ->
    super
    @showAsModal()
    @$('.contentModal').customCheckbox()
    @$('form#wbi-login-form').validate
      rules:
        email:
          required: true
          email: true
        password:
          required: true
          minlength: 2

  showAsModal: ->
    $('<a>').wbfancybox(href: '#' + @id, onClosed: -> utils.redirectTo controller: 'home', action: 'index').click()

  doLogin:(e) ->
    e.preventDefault()
    @$('.errorDiv').css('display':'none')
    $form = $(e.currentTarget).closest('form')
    if utils.validateForm($form)
      formData = verticalId: env.get('current-vertical-id')
      formData = utils.serializeForm($form, formData)
      $.extend(formData, utms: trackingUtils.getUTMs())
      $submitButton = @$('#wbi-login-in-btn').prop('disabled', yes)

      @model.requestLogin(formData, context: @)
        .done(@doLoginSuccess)
        .fail(@doLoginError)

  doLoginSuccess: (data) ->
    mediator.data.set 'profile-composed', no
    response = data.response
    loginUtils.applyLogin(response)
    @doCheckShowRemainder(data)

  doCheckShowRemainder:(data)->
    if data.response.showRemainder is yes
      message = "Recuerda que puedes ganar $#{data.response.cashbackForComplete} en bits al completar tu registro"
      value = 'Completa registro'
      options =
        value: value
        title:"¡#{value}!"
        cancelValue: 'Llénalo después'
        icon:'iconFont-computer'
        context: @
        acceptAction: () ->
          Winbits.$('#wbi-my-account-link').click()
          utils.closeMessageModal()
      utils.showConfirmationModal(message, options)
    else
      $.fancybox.close()

    utils.redirectTo(controller: 'logged-in', action: 'index')

  doLoginError: (xhr, textStatus) ->
    error = utils.safeParse(xhr.responseText)
    message = if error then error.meta.message else textStatus
    defaultOptionsMessage=
      message : "Error"
      title : "Error"
      icon : "ok"
    code = error.code or error.meta.code
    if code is 'AFER004'
      resendConfirmUrl = decodeURIComponent error.response.resendConfirmUrl
      @confirmURL = resendConfirmUrl.substring(resendConfirmUrl.indexOf('users')).replace(/\+/g,'%252b')
      defaultOptionsMessage = @errorWhenIsAFER004 defaultOptionsMessage
      @showMessageErrorModal(defaultOptionsMessage)
    else
      @$('.errorDiv p').text(message).parent().css('display':'block')
      @$('#wbi-login-in-btn').prop('disabled', no)

  doFacebookLogin: (e) ->
    e.preventDefault()
    @publishEvent 'facebook-button-event', e

  showMessageErrorModal: (defaultOptionsMessage)->
    options =
      value: defaultOptionsMessage.value
      title: defaultOptionsMessage.title
      icon:"iconFont-#{defaultOptionsMessage.icon}"
      context: defaultOptionsMessage.context
      acceptAction: defaultOptionsMessage.acceptAction
      onClosed: utils.redirectToNotLoggedInHome()
    utils.showMessageModal(defaultOptionsMessage.message, options)

  errorWhenIsAFER004: (defaults) ->
    options =
      message :"Esta cuenta ya esta registrada,es necesario confirmar tu cuenta de correo. Si no encuentras nuestro mail de confirmación, revisa tu bandeja de SPAM"
      value : "Reenviar correo de confirmación"
      title : "Mail no confirmado"
      icon : "computerDoc"
      context: @
      acceptAction : @doRequestResendConfirmationMail
      onClosed: $.noop
    $.extend(defaults, options)

  doRequestResendConfirmationMail: () ->
    loginUtils.requestResendConfirmationMail(@confirmURL)
    .done(@doSuccessRequestResendConfirmationMail)
    .fail(@doErrorRequestResendConfirmationMail)

  doErrorRequestResendConfirmationMail: ->
    message = 'Por el momento no se ha podido enviarte el correo de confirmación, por favor intentalo mas tarde'
    options =
      value: 'Aceptar'
      title: 'Error al enviar el correo.'
      icon: "iconFont-email"
      acceptAction: ->
        utils.redirectTo(controller:'home', action:'index')
        $.fancybox.close()
    utils.showMessageModal(message, options)

  doSuccessRequestResendConfirmationMail: ->
    message = 'Un mensaje de confirmación ha sido enviado a tu cuenta de correo.'
    options =
      value: 'Aceptar'
      title: 'Correo Enviado'
      icon: "iconFont-email2"
      acceptAction: ->
        utils.redirectTo(controller:'home', action:'index')
        $.fancybox.close()
    utils.showMessageModal(message, options)

