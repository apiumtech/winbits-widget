'use strict'

CardView = require 'views/cards/card-view'
utils = require 'lib/utils'
$ = Winbits.$

module.exports = class NewCardView extends CardView
  id: 'wbi-new-card-view'

  initialize: ->
    super
    @delegate 'click', '#wbi-save-card-btn', @saveNewCard

  saveNewCard: ->
    $form = @$('.wbc-card-form')
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

