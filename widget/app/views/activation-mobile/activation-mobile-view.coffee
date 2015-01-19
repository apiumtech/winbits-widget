'use strict'
$ = Winbits.$
View = require 'views/base/view'
utils = require 'lib/utils'
mediator = Winbits.Chaplin.mediator

module.exports = class ActivationMobileView extends View
  container: '#wbi-winbits-modals'
  id: 'wbi-activation-mobile'
  template: require './templates/activation-mobile-view'

  initialize: ->
    super
    @delegate 'click', '#wbi-activation-button', @validateForm
    @delegate 'click', '#wbi-resend-activation-code', @resendCodeToUser
    @delegate 'click', '#wbi-change-activation-mobile', @returnSmsModal


  attach: ->
    super
    @showAsModal()
    @$('.wbc-activation-mobile-form').validate
      errorElement: 'p'
      rules:
        code:
          required: yes
          minlength: 5
          maxlength: 5

  showAsModal: ->
    $('<a>').wbfancybox(href: '#wbi-activation-mobile', onClosed: -> utils.redirectTo controller: 'logged-in', action: 'index').click()


  validateForm:(e)->
    e.preventDefault()
    $form = @$('.wbc-activation-mobile-form')
    formData = utils.serializeForm $form
    if utils.validateForm($form)
      @send(formData)

  send:(formData) ->
    @model.requestActivateMobile(formData, context: @)
    .done(@sendSuccess)
    .fail(@sendError)

  sendSuccess:()->
    loginData= mediator.data.get('login-data')
    loginData.mobileActivationStatus='ACTIVE'
    message = "Tu número ha sido activado."
    options = value: "Cerrar", title:'¡ Listo !', icon:'iconFont-ok', onClosed: utils.redirectToLoggedInHome()
    utils.showMessageModal(message, options)
    @publishEvent 'profile-changed', response: loginData

  sendError: (xhr)->
    error = utils.safeParse(xhr.responseText)
    messageText = "Error activando el número de celular, favor de intentarlo más tarde"
    message = if error then error.meta.message else messageText
    options = value: "Cerrar", title:'Error', icon:'iconFont-info', onClosed: utils.redirectToLoggedInHome()
    utils.showMessageModal(message, options)

  returnSmsModal:(e) ->
    e.preventDefault()
    utils.redirectTo(controller: 'sms', action: 'index')

  resendCodeToUser:(e) ->
    e.preventDefault()
    @model.requestSendMessage(mobile: @model.get('mobile'), context: @)
    .done(@resendCodeSuccess)
    .fail(@resendCodeError)

  resendCodeSuccess:() ->
    $('#wbi-resend-success-label').show()

  resendCodeError:() ->
    $('#wbi-resend-error-label').show()


