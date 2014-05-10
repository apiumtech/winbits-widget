'use strict'

require = Winbits.require
Model = require 'models/base/model'
utils = require 'lib/utils'
$ = Winbits.$
env = Winbits.env

module.exports = class Cards extends Model
  url: utils.getResourceURL('orders/card-subscription.json')
  needsAuth: yes

  initialize: () ->
    super

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
