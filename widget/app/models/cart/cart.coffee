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

  initialize: () ->
    super
    @cachedUrl = @url()

  sync: (method, model, options = {}) ->
    options.headers = 'Wb-VCart': utils.getVirtualCart() if not utils.isLoggedIn()
    super(method, model, options)

  addToUserCart: (cartItems = {}) ->
    cartItems = @fixCartItemsParam(cartItems)
    options =
      headers:
        'Wb-Api-Token': utils.getApiToken()
    utils.ajaxRequest(@cachedUrl, @applyDefaultAddToCartRequestDefaults(cartItems, options)

  addToVirtualCart: (cartItems = {}) ->
    cartItems = @fixCartItemsParam(cartItems)
    options =
      headers:
        'Wb-VCart': utils.getVirtualCart()
    utils.ajaxRequest(@cachedUrl, @applyDefaultAddToCartRequestDefaults(cartItems, options)

  fixCartItemsParam: (cartItems) ->
    if $.isArray(cartItems) then cartItems else [cartItems]

  applyDefaultAddToCartRequestDefaults: (cartItems, options = {}) ->
    defaults =
      type: 'POST'
      dataType: 'json'
      data: JSON.stringify(cartItems)

    requestOptions = $.extends({}, options)
    requestOptions.headers = $.extends('Accept-Language': 'es', options.headers)
    requestOptions
