'use strict'

View = require 'views/base/view'
Card = require 'models/cards/card'
utils = require 'lib/utils'
$ = Winbits.$

module.exports = class NewCardView extends View
  container: '#wb-credit-cards'
  id: 'wbi-new-card-view'
  className: 'creditcardNew'
  template: require './templates/new-card'
  model: new Card

  initialize: ->
    super
    @delegate 'click', '#wbi-save-card-btn', @saveNewCard
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
        if name in ['expirationMonth', 'expirationYear']
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

  saveNewCard: ->
    $form = @$('#wbi-new-card-form')
    if $form.valid()
      utils.showAjaxLoading()
      cardData = utils.serializeForm($form)
      @model.requestSaveNewCard(cardData, @)
          .done(@saveNewCardSucceds)
          .always(@saveNewCardCompletes)

  saveNewCardSucceds: ->
    @publishEvent('cards-changed')
    options =
      acceptAction: @hideNewCardView
      context: @
    utils.showMessageModal('Tus datos fueron guardados correctamente.', options)

  saveNewCardCompletes: ->
    utils.hideAjaxLoading()

  hideNewCardView: ->
    @$el.slideUp()
    @publishEvent('card-subview-hidden')
