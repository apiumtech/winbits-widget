# Cart-specific utilities
# ------------------------------

utils = require 'lib/utils'
$ = Winbits.$
env = Winbits.env
_ = Winbits._

cartUtils = {}
_(cartUtils).extend
  getCartResourceUrl: ->
    resource = if utils.isLoggedIn() then 'cart-items.json' else 'virtual-cart-items.json'
    env.get('api-url') + "/orders/#{resource}"

  addToUserCart: (cartItems = {}) ->
    cartItems = @transformCartItems(cartItems)
    options =
      headers:
        'Wb-Api-Token': utils.getApiToken()
    utils.ajaxRequest(@getCartResourceUrl(), @applyDefaultAddToCartRequestDefaults(cartItems, options))

  addToVirtualCart: (cartItems = {}) ->
    cartItems = @transformCartItems(cartItems)
    options =
      headers:
        'Wb-VCart': utils.getVirtualCart()
    utils.ajaxRequest(@getCartResourceUrl(), @applyDefaultAddToCartRequestDefaults(cartItems, options))
    .done((data)-> utils.saveVirtualCart(data.response))

  transformCartItems: (cartItems) ->
    (@transformCartItem(x) for x in cartItems)

  transformCartItem: (cartItem) ->
    skuProfileId: cartItem.id
    quantity: cartItem.quantity
    bits: cartItem.bits

  applyDefaultAddToCartRequestDefaults: (cartItems, options = {}) ->
    defaults =
      type: 'POST'
      dataType: 'json'
      data: JSON.stringify(cartItems: cartItems)
      headers:
        'Accept-Language': 'es'
        'Content-Type': 'application/json;charset=utf-8'

    requestOptions = $.extend({}, defaults, options)
    requestOptions.headers = $.extend({}, defaults.headers, options.headers)
    requestOptions

# Prevent creating new properties and stuff.
Object.seal? cartUtils

module.exports = cartUtils
