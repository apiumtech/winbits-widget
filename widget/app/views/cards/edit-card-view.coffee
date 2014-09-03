'use strict'

CardView = require 'views/cards/card-view'
utils = require 'lib/utils'
$ = Winbits.$

module.exports = class EditCardView extends CardView
  id: 'wbi-edit-card-view'
  template: require './templates/edit-card'

  initialize: ->
    super
    @delegate 'click', '.wbc-save-card-btn', @updateCard

  updateCard: (e) ->
    $form = @$('.wbc-card-form')
    if $form.valid()
      cardData = utils.serializeForm($form)
      utils.showAjaxLoading()
      @model.requestUpdateCard(cardData, @)
          .done(@requestUpdateCardSucceds)
          .fail(@requestUpdateCardError)
          .always(@requestUpdateCardCompletes)

  requestUpdateCardSucceds: ->
    @publishEvent('cards-changed')
    options =
      context: @
      icon: 'iconFont-ok'
      onClosed: @hideCardView
    utils.showMessageModal('Tus datos se han guardado correctamente.', options)

  requestUpdateCardError:(xhr, textStatus)->
    error = utils.safeParse(xhr.responseText)
    message = if error then error.meta.message else textStatus
    utils.showError(message)


  requestUpdateCardCompletes: ->
    utils.hideAjaxLoading()
