'use strict'

View = require 'views/base/view'
Card = require 'models/cards/card'
utils = require 'lib/utils'
$ = Winbits.$

module.exports = class CardView extends View
  container: '#wb-credit-cards'
  className: 'creditcardNew'
  template: require './templates/card'
  model: new Card

  initialize: ->
    super
    @delegate 'click', '.wbc-cancel-btn', @hideNewCardView

  attach: ->
    super
    @$('.requiredField').requiredField()
    @$('.wbc-country-field').customSelect()
    @$('[name=cardPrincipal]').parent().customCheckbox()
    required =
      required: yes
      minlength: 1
    @$('#wbi-new-card-form').validate(
      ignore: ''
      groups:
        cardExpiration: 'expirationMonth expirationYear'
        streetAndNumber: 'street1 number'
      errorPlacement: ($error, $element) ->
        name = $element.attr('name')
        $errorPlaceholder = $element.closest('.wbc-error-placeholder')
        if name in ['expirationMonth', 'expirationYear', 'accountNumber']
          $error.appendTo $errorPlaceholder
        else if name in ['street1', 'number']
          $error.insertAfter $errorPlaceholder.find('[name=number]').parent()
        else if name is 'country'
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
          minlength: 15
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
        colony:
          required: yes
        city:
          required: yes
        country:
          required: yes
      messages:
        expirationMonth:
          range: $.validator.messages.wbExpirationMonth
          digits: $.validator.messages.wExpirationMonth
        postalCode:
          remote: $.validator.messages.wbZipCode
    )
    @$('[name=accountNumber]').on('textchange', $.proxy(@updateCardLogo, @))

  hideNewCardView: ->
    @$el.slideUp()
    @publishEvent('card-subview-hidden')

  updateCardLogo: (e)->
    $cardNumberField = $(e.currentTarget)
    cardTypeDataKey = 'card-type'
    cardNumber = $cardNumberField.val()
    cardType = utils.getCreditCardType(cardNumber)
    cardTypeClass = "iconFont-#{cardType}"
    currentCardType = $cardNumberField.data(cardTypeDataKey)
    currentCardTypeClass = "iconFont-#{currentCardType}"
    @$('.wbc-card-logo').removeClass(currentCardTypeClass).addClass(cardTypeClass)
    $cardNumberField.data(cardTypeDataKey, cardType)
    @fixCardNumberMaxLengthByCardType(cardType, $cardNumberField)

  fixCardNumberMaxLengthByCardType: (cardType, $cardNumberField)->
    maxLength = if cardType isnt 'amex' then 16 else 15
    $cardNumberField.attr('maxlength', maxLength)
