'use strict'
$ = Winbits.$
View = require 'views/base/view'
utils = require 'lib/utils'
mediator = Winbits.Chaplin.mediator

module.exports = class SmsModalView extends View
  container: '#wbi-winbits-modals'
  id: 'wbi-sms-modal'
  template: require './templates/sms-modal-view'

  initialize: ->
    super
    @delegate 'click', '#wbi-sms-button', @validateForm

  attach: ->
    super
    @$('.select').customSelect();
    @showAsModal()
    @$('.wbc-sms-modal-form').validate
      errorElement: 'p'
      errorPlacement: ($error, $element) ->
        if $element.attr("name") in ["carrier"]
          $error.insertAfter $element.parent()
        else
          $error.insertAfter $element
      rules:
        mobile:
          required: yes
          number: yes
          minlength: 10
        carrier:
          required: yes

  showAsModal: ->
    $('<a>').wbfancybox(href: '#wbi-sms-modal', onClosed: -> utils.redirectTo controller: 'logged-in', action: 'index').click()


  validateForm:(e)->
    e.preventDefault()
    $form = @$('.wbc-sms-modal-form')
    formData = utils.serializeForm $form
    if utils.validateForm($form)
      @send(formData)

  send:(formData) ->
    console.log ["Send function", formData]
    @$('#wbi-sms-button').prop('disabled', yes)
    @model.requestSendMessage(formData, context: @)
      .done(@sendSuccess)
      .fail(@sendError)
      .always(->  @$('#wbi-sms-button').prop('disabled', no))

  sendSuccess:(data)->
    mediator.data.set('activation-data', data.response)
    loginData= mediator.data.get('login-data')
    loginData.profile.phone = data.response.mobile
    utils.redirectTo(controller: 'activation-mobile', action: 'index')
    @publishEvent 'profile-changed', response: loginData

  sendError: (xhr)->
    error = utils.safeParse(xhr.responseText)
    messageText = "Error activando el número de celular, favor de intentarlo más tarde"
    message = if error then error.meta.message else messageText
    options = value: "Cerrar", title:'Error', onClosed: utils.redirectToLoggedInHome()
    utils.showMessageModal(message, options)