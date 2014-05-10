'use strict'

require = Winbits.require
Model = require 'models/base/model'
utils = require 'lib/utils'
$ = Winbits.$

module.exports = class Card extends Model
  needsAuth: yes

  initialize: ->
    super

  requestSaveNewCard: (cardData, context = @)->
    options =
      type: 'POST'
      data: JSON.stringify(cardData)
      context: context
    url = utils.getResourceURL('orders/card-subscription.json')
    utils.ajaxRequest(url, options)
