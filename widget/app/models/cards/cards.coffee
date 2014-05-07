require = Winbits.require
Model = require 'models/base/model'
utils = require 'lib/utils'
cartUtils = require 'lib/cart-utils'
mediator = Chaplin.mediator
$ = Winbits.$
env = Winbits.env

module.exports = class Cart extends Model
  url: utils.getResourceURL('orders/card-subscription.json')
  needsAuth: yes

  initialize: () ->
    super

  parse: ->
    parsedResponse = super
    cards: parsedResponse

  requestSetDefaultCard: ->
