'use strict'

require = Winbits.require
Model = require 'models/base/model'
utils = require 'lib/utils'
$ = Winbits.$

module.exports = class Card extends Model
  needsAuth: yes
  accessors: ['cardTypeClass']

  initialize: ->
    super

  requestSaveNewCard: (cardData, context = @)->
    options =
      type: 'POST'
      data: JSON.stringify(paymentInfo: cardData)
      context: context
      headers:
        'Wb-Api-Token': utils.getApiToken()
    url = utils.getResourceURL('orders/card-subscription.json')
    utils.ajaxRequest(url, options)
        .fail($.proxy(utils.showApiError, utils))

  cardTypeClass: ->
    'iconFont-visa'
