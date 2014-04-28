require = Winbits.require
Model = require 'models/base/model'
utils = require 'lib/utils'
mediator = Chaplin.mediator
$ = Winbits.$
env = Winbits.env

module.exports = class Cart extends Model
  url: ->
    resource = if utils.isLoggedIn() then 'cart-items.json' else 'virtual-cart-items.json'
    env.get('api-url') + "/orders/#{resource}"
  needsAuth: yes
  defaults:
    itemsTotal: 0,
    bitsTotal: 0,
    shippingTotal: 0,
    cashback: 0

  sync: (method, model, options = {}) ->
    options.headers = 'Wb-VCart': utils.getVirtualCart() if not utils.isLoggedIn()
    super(method, model, options)
