'use strict'
View = require 'views/base/view'
utils = require 'lib/utils'
$ = Winbits.$
env = Winbits.env

module.exports = class ModalRegisterView extends View
  container: '#wbi-winbits-modals'
  id: 'wbi-register-modal'
  template: require './templates/register'

  initialize: ->
    super
    @delegate 'click', '#wbi-register-button', @register
    @delegate 'click', '#wbi-register-facebook-link', @doFacebookRegister

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
    @$('.errorDiv').css('display':'none')
    e.preventDefault()
    $form =  @$("#wbi-register-form")
    formData = verticalId: env.get('current-vertical-id')
    formData = utils.serializeForm($form, formData)
    if utils.validateForm($form)
      submitButton = @$(e.currentTarget).prop('disabled', true)
      @model.requestRegisterUser(formData, context:@)
        .done @doRegisterSuccess
        .fail @doRegisterError
        .always(-> submitButton.prop('disabled', false))


  doRegisterSuccess: (data) ->
    console.log "Request Success!"
    message = "Gracias por registrarte con nosotros. <br> Un mensaje de confirmación ha sido enviado a tu <br> cuenta de correo."
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
      message = if error then error.meta.message else textStatus
    @showMessageErrorModal(defaultOptionsMessage)

  errorWhenIsAFER001: (defaults) ->
    options =
      message : "Esta cuenta de correo ya está registrada. Si no recuerdas tu contraseña, da click en recuperar contraseña."
      value : "Recuperar contraseña"
      title : "Cuenta registrada"
      icon : "candado"
      acceptAction : () -> utils.redirectTo(controller:'recover-password', action:'index')
    $.extend(defaults, options)
    defaults

  showMessageErrorModal: (defaultOptionsMessage)->
    options =
      value: defaultOptionsMessage.value
      title: defaultOptionsMessage.title
      icon:"iconFont-#{defaultOptionsMessage.icon}"
      onClosed: utils.redirectToNotLoggedInHome()
      acceptAction: defaultOptionsMessage.acceptAction
    utils.showMessageModal(defaultOptionsMessage.message, options)

  doFacebookRegister: (e) ->
    e.preventDefault()
    @publishEvent 'facebook-button-event', e