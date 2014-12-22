'use strict'
$ = Winbits.$
View = require 'views/base/view'
utils = require 'lib/utils'

module.exports = class ActivationMobileView extends View
  container: '#wbi-winbits-modals'
  id: 'wbi-activation-mobile'
  template: require './templates/activation-mobile-view'

  initialize: ->
    super
    @delegate 'click', '#wbi-activation-button', @validateForm
    @delegate 'click', '#wbi-resend-activation-code', -> console.log ["click resend code"]
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
    console.log ["Send function"]
    @model.requestSendMessage(formData, context: @)

  returnSmsModal:(e) ->
    e.preventDefault()
    utils.redirectTo(controller: 'sms', action: 'index')
