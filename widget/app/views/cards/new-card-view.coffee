'use strict'

CardView = require 'views/cards/card-view'
utils = require 'lib/utils'
$ = Winbits.$
mediator = Winbits.Chaplin.mediator

module.exports = class NewCardView extends CardView
  id: 'wbi-new-card-view'

  initialize: ->
    super
    @delegate 'click', '.wbc-save-card-btn', @saveNewCard
    @delegate 'change', '#wbi-copy-address', @doCopyAddress
  
  doCopyAddress:(e) ->
    if @$('#wbi-copy-address').prop('checked') is yes
      @fillCardWithMain()
    else
      @cleanCardData()

  saveNewCard: ->
    $form = @$('.wbc-card-form')
    if $form.valid()
      utils.showAjaxLoading()
      cardData = utils.serializeForm($form)
      delete cardData['copyAddress']
      @model.requestSaveNewCard(cardData, @)
          .done(@saveNewCardSucceds)
          .always(@saveNewCardCompletes)

  saveNewCardSucceds: ->
    @publishEvent('cards-changed')
    options =
      onClosed: @hideCardView
      context: @
      icon: 'iconFont-ok'
    utils.showMessageModal('Tus datos se han guardado correctamente.', options)

  saveNewCardCompletes: ->
    utils.hideAjaxLoading()
  
  fillCardWithMain: ->
    mainAddress = mediator.data.get 'main-address'
    if mainAddress isnt null
      @$('#winbitsCreditCard').val(mainAddress.firstName)
      lastName = @obtainFullLastName(mainAddress.lastName, mainAddress.lastName2)
      @$('#winbitsCreditCardLastname').val(lastName) 
      @$('#winbitsCreditCardStreet').val(mainAddress.street)
      fullNumber = @obtainFullNumber(mainAddress.externalNumber, mainAddress.internalNumber)
      @$('#winbitsCreditCardNum').val(fullNumber)
      @$('#winbitsCreditCardCity').val(mainAddress.county)
      @$('#winbitsCreditCardState').val(mainAddress.state)
      @$('#winbitsCreditCardCP').val(mainAddress.zipCode)
      @$('#winbitsCreditCardTel').val(mainAddress.phone)
  
  cleanCardData: ->
    $('#winbitsCreditCard').val('')
    $('#winbitsCreditCardLastname').val('') 
    $('#winbitsCreditCardStreet').val('')
    $('#winbitsCreditCardNum').val('')
    $('#winbitsCreditCardCity').val('')
    $('#winbitsCreditCardState').val('')
    $('#winbitsCreditCardCP').val('')
    $('#winbitsCreditCardTel').val('')
 
  obtainFullLastName:(lastName, lastName2) ->
    fullLastName = lastName
    if lastName2
      fullLastName = lastName + ' ' + lastName2
    fullLastName

  obtainFullNumber: (intNumber, extNumber) ->    
    fullNumber = intNumber
    if extNumber
      fullNumber = intNumber + ' ' + extNumber    
    fullNumber  

