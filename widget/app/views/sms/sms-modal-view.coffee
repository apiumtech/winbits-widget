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
    @showAsModal()
    @$('.wbc-sms-modal-form').validate
      errorElement: 'p'
      rules:
        cellphone:
          required: yes
          number: yes
          minlength: 10

  showAsModal: ->
    $('<a>').wbfancybox(href: '#wbi-sms-modal', onClosed: -> utils.redirectTo controller: 'logged-in', action: 'index').click()


  validateForm:(e)->
    e.preventDefault()
    $form = @$('.wbc-sms-modal-form')
    formData = utils.serializeForm $form
    if utils.validateForm($form)
      @send(formData)

  send:(formData) ->
    console.log ["Send function"]
    @$('#wbi-sms-button').prop('disabled', yes)
    @model.requestSendMessage(formData, context: @)
      .done(@sendSuccess)
      .fail(@sendError)
      .always(->  @$('#wbi-sms-button').prop('disabled', no))

  sendSuccess:(data)->
    mediator.data.set('activation-data', data.response)
    utils.redirectTo(controller: 'activation-mobile', action: 'index')

  sendError: (xhr)->
    error = utils.safeParse(xhr.responseText)
    messageText = "Error activando el número de celular, favor de intentarlo más tarde"
    message = if error then error.meta.message else messageText
    options = value: "Cerrar", title:'Error', onClosed: utils.redirectToLoggedInHome()
    utils.showMessageModal(message, options)