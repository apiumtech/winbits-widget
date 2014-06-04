'use strict'

require = Winbits.require
Model = require 'models/base/model'
utils = require 'lib/utils'
$ = Winbits.$
_ = Winbits._
env = Winbits.env

module.exports = class Cards extends Model
  url: utils.getResourceURL('orders/card-subscription.json')
  needsAuth: yes

  initialize: () ->
    super
    @subscribeEvent 'cards-changed', -> @fetch()

  parse: ->
    parsedResponse = super
    cards: parsedResponse

  requestSetDefaultCard: (id, context = @) ->
    url = utils.getResourceURL("orders/card-subscription/#{id}/main.json")
    options =
      type: "PUT"
      context: context
      headers:
        'Wb-Api-Token': utils.getApiToken()
    utils.ajaxRequest(url, options)
        .fail($.proxy(@requestSetDefaultCardFailed, @))

  requestSetDefaultCardFailed: ->
    console.log('Error al establecer la tarjeta como principal.')

  getCardById: (cardId) ->
    cardId = cardId.toString() if cardId
    cards = @get('cards')
    _.find(cards, (card) -> card.cardInfo.subscriptionId is cardId)

  requestDeleteCard: (cardId, context) ->
    path = "orders/card-subscription/#{cardId}.json"
    options =
      type: 'DELETE'
      context: context
      headers:
        'Wb-Api-Token': utils.getApiToken()
    utils.ajaxRequest(utils.getResourceURL(path), options)
        .fail(@requestDeleteCardFails)

  requestDeleteCardFails: (xhr) ->
    utils.showApiError(xhr)

  deleteCard: (cardId) ->
    cardId = cardId.toString() if cardId
    cards = @get('cards')
    newCards = _.filter(cards, (card) ->
      card.cardInfo.subscriptionId isnt cardId
    )
    @set('cards', newCards)
