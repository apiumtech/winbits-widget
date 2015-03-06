'use strict'

View = require 'views/base/view'
utils = require 'lib/utils'
mediator = Winbits.Chaplin.mediator
$ = Winbits.$
env = Winbits.env




module.exports = class verifyMobileView extends View
  container: '#wb-profile'
  id : 'wbi-verify-mobile'
  className: 'column miCuenta-mobile'
  template: require './templates/verify-mobile-view'

  initialize: ->
    super
    @delegate 'click', '#wbi-resend-label', @reSend
    @delegate 'click', '#wbi-validate-button', @validateCodebtn
    @subscribeEvent 'profile-changed', @attach

  attach: ->
    super
    form =  @$('.wbc-activation-mobile-form')
    container = $('#wbi-verify-mobile')
    if(mediator.data.get('login-data').mobileActivationStatus == 'WAIT')
      container.show()
      form.validate
        rules:
          code:
            required: yes
            minlength: 5
            maxlength: 5
    else
      container.hide()



  reSend: (e) ->
    e.preventDefault()
    message = "Se enviará una vez más el código de activación"
    value = 'Aceptar'
    options =
      value: value
      title:"¡#{value}!"
      cancelValue: 'Cancelar'
      icon:'iconFont-computer'
      context: @
      acceptAction: (e) ->
        Winbits.$(e.currentTarget).prop('disabled', yes)
        @model.reSendCodeToClient(context: @)
          .done(@reSendSuccess)
          .fail(@reSendError)
    utils.showConfirmationModal(message, options)


  validateCodebtn:(e) ->
     $form = @$('.wbc-activation-mobile-form')
     formData = utils.serializeForm $form
     if utils.validateForm($form)
       @sendCode(formData)


  sendCode:(formData) ->
     @$('#wbi-validate-button').prop('disabled', yes)
     @model.sendCodeForActivationMobile(formData, context: @)
      .done(@sendSuccess)
      .fail(@sendError)
      .always(-> @$('#wbi-validate-button').prop('disabled', no))

  sendSuccess:()->
    message = "Tu número ha sido activado."
    options = value: "Cerrar", title:'¡ Listo !', icon:'iconFont-ok', onClosed: utils.redirectToLoggedInHome()
    loginData = mediator.data.get('login-data')
    loginData.mobileActivationStatus = "ACTIVE"
    mediator.data.set('login-data',loginData)
    utils.showMessageModal(message, options)
    @publishEvent 'profile-changed', response: loginData


  sendError: (xhr)->
    error = utils.safeParse(xhr.responseText)
    messageText = "Error activando el número de celular, favor de intentarlo más tarde"
    message = if error then error.meta.message else messageText
    options = value: "Cerrar", title:'Error', icon:'iconFont-info', onClosed: utils.redirectToLoggedInHome()
    utils.showMessageModal(message, options)


  reSendSuccess:()->
    message = "Te hemos enviado el código a tu celular. Valídalo desde la opción VERIFICACIÓN MÓVIL"
    options = value: "Cerrar", title:'¡ Listo !', icon:'iconFont-ok', onClosed: utils.redirectToLoggedInHome()
    utils.showMessageModal(message, options)


  reSendError: (xhr)->
    error = utils.safeParse(xhr.responseText)
    messageText = "Error al enviar el código a tu celular, favor de intentarlo más tarde"
    message = if error then error.meta.message else messageText
    options = value: "Cerrar", title:'Error', icon:'iconFont-info', onClosed: utils.redirectToLoggedInHome()
    utils.showMessageModal(message, options)
