'use strict'

View = require 'views/base/view'
utils = require 'lib/utils'
$ = Winbits.$
INVALID_MONTH_MESSAGE = 'Escribe una fecha válida.'

module.exports = class NewCardView extends View
  container: '#wb-credit-cards'
  id: 'wbi-new-card-view'
  className: 'creditcardNew'
  template: require './templates/new-card'

  initialize: ->
    super

  attach: ->
    super
    @$('.wbc-country-field').customSelect()
    @$('[name=cardPrincipal]').parent().customCheckbox()
    @$('#wbi-new-card-form').validate(
      groups:
        cardExpiration: 'expirationMonth expirationYear'
      errorPlacement: ($error, $element) ->
        if $element.attr('name') in ['expirationMonth', 'expirationYear']
          $error.appendTo $element.parent()
        else
          $error.insertAfter $element
      errorElement: 'span'
      rules:
        firstName:
          required: yes
          minlength: 2
        lastName:
          required: yes
          minlength: 2
        accountNumber:
          required: yes
          creditcard: yes
        expirationMonth:
          required: yes
          minlength: 2
          digits: yes
          range: [1, 12]
        expirationYear:
          required: yes
          minlength: 2
          digits: yes
        # cvNumber:
        #   required: yes
        #   digits: yes
        #   minlength: 3
        street1:
          required: yes
        number:
          required: yes
        postalCode:
          required: yes
          wbZipCode: yes
          remote: utils.getResourceURL('users/validate/zip-code.json')
        phoneNumber:
          required: yes
          wbiPhone: yes
        state:
          required: yes
        colony:
          required: yes
        city:
          required: yes
      messages:
        expirationMonth:
          range: INVALID_MONTH_MESSAGE
          digits: INVALID_MONTH_MESSAGE
        postalCode:
          remote: 'Ingresa un CP válido.'
    )
