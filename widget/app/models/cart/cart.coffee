require = Winbits.require
Model = require 'models/base/model'
utils = require 'lib/utils'
cartUtils = require 'lib/cart-utils'
mediator = Chaplin.mediator
$ = Winbits.$

module.exports = class Cart extends Model
  url: cartUtils.getCartResourceUrl
  needsAuth: yes
  accessors: ['cartTotal', 'cartPercentageSaved']
  defaults:
    itemsTotal: 0,
    bitsTotal: 0,
    shippingTotal: 0,
    cashback: 0

  initialize: () ->
    super

  sync: (method, model, options = {}) ->
    options.headers = 'Wb-VCart': utils.getVirtualCart() if not utils.isLoggedIn()
    super(method, model, options)

  cartTotal: ->
    @get('itemsTotal') - @get('shippingTotal') - @get('bitsTotal')

  cartPercentageSaved: ->
    cartTotal = @cartTotal()
    itemsTotal = @get('itemsTotal')
    if itemsTotal then (1 - (cartTotal / itemsTotal)) * 100 else 0
