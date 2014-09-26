'use strict'
View = require 'views/base/view'
utils = require 'lib/utils'
trackingUtils = require 'lib/tracking-utils'
loginUtils = require 'lib/login-utils'
$ = Winbits.$
env = Winbits.env

module.exports = class ModalRegisterView extends View
  container: '#wbi-winbits-modals'
  id: 'wbi-register-modal'
  template: require './templates/register'

  initialize: ->
    super
    @delegate 'click', '#wbi-register-button', @register
    @delegate 'click', '#wbi-facebook-link', @doFacebookRegister

  attach: ->
    super
    @showAsModal()
    @$('#wbi-register-form').validate
      rules:
        email:
          required: true
          email: true
        password:
          required: true
          minlength: 6
        passwordConfirm:
          required: true
          minlength: 6
          equalTo: @$("[name=password]")

  showAsModal: ->
    $('<a>').wbfancybox(href: '#wbi-register-modal', onClosed: -> utils.redirectTo controller: 'home', action: 'index').click()

  register: (e)->
    e.preventDefault()
    @$('.errorDiv').css('display':'none')
    $form =  @$("#wbi-register-form")
    formData = verticalId: env.get('current-vertical-id')
    formData = utils.serializeForm($form, formData)
    $.extend(formData, utms: trackingUtils.getUTMs())
    if utils.validateForm($form)
      submitButton = @$(e.currentTarget).prop('disabled', true)
      @model.requestRegisterUser(formData, context:@)
        .done @doRegisterSuccess
        .fail @doRegisterError
        .always(-> submitButton.prop('disabled', false))


  doRegisterSuccess: (data) ->
    console.log "Request Success!"
    message = "Gracias por registrarte con nosotros. Un mensaje de confirmación ha sido enviado a tu cuenta de correo."
    options = value: "Continuar", title:'Registro Exitoso', icon:'iconFont-ok', onClosed: utils.redirectTo controller: 'home', action: 'index'
    utils.showMessageModal(message, options)

  doRegisterError: (xhr, textStatus) ->
    error = utils.safeParse(xhr.responseText)
    defaultOptionsMessage=
      message : "Error"
      title : "Error"
      icon : "ok"
    code = error.code or error.meta.code
    if code is 'AFER001'
      defaultOptionsMessage = @errorWhenIsAFER001 defaultOptionsMessage

    if code is 'AFER026'
      resendConfirmUrl = error.response.resendConfirmUrl
      @confirmURL = resendConfirmUrl.substring(resendConfirmUrl.indexOf('users')).replace(/\+/g,"%252b")
      console.log "Confirm url #{@confirmURL}"
      defaultOptionsMessage = @errorWhenIsAFER206 defaultOptionsMessage

    @showMessageErrorModal(defaultOptionsMessage)


  errorWhenIsAFER206: (defaults) ->
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

  errorWhenIsAFER001: (defaults) ->
    options =
      message : "Esta cuenta de correo ya está registrada. Si no recuerdas tu contraseña, da click en recuperar contraseña."
      value : "Recuperar contraseña"
      title : "Cuenta registrada"
      icon : "candado"
      acceptAction : () -> utils.redirectTo(controller:'recover-password', action:'index')
    $.extend(defaults, options)

  showMessageErrorModal: (defaultOptionsMessage)->
    options =
      value: defaultOptionsMessage.value
      title: defaultOptionsMessage.title
      icon:"iconFont-#{defaultOptionsMessage.icon}"
      context: defaultOptionsMessage.context
      acceptAction: defaultOptionsMessage.acceptAction
      onClosed: defaultOptionsMessage.onClosed ? utils.redirectToNotLoggedInHome()
    utils.showMessageModal(defaultOptionsMessage.message, options)

  doFacebookRegister: (e) ->
    e.preventDefault()
    @publishEvent 'facebook-button-event', e
