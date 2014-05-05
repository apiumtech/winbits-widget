# Cart-specific utilities
# ------------------------------

utils = require 'lib/utils'
EventBroker = Chaplin.EventBroker
$ = Winbits.$
env = Winbits.env
_ = Winbits._

cartUtils = {}
_(cartUtils).extend
  getCartResourceUrl:(itemId) ->
    resource
    if not itemId
      resource = if utils.isLoggedIn() then 'cart-items.json' else 'virtual-cart-items.json'
    else
      resource = if utils.isLoggedIn() then "cart-items/#{itemId}.json" else "virtual-cart-items/#{itemId}.json"
    env.get('api-url') + "/orders/#{resource}"

  addToUserCart: (cartItems = {}) ->
    cartItems = @transformCartItems(cartItems)
    options =
      headers:
        'Wb-Api-Token': utils.getApiToken()
    utils.ajaxRequest(@getCartResourceUrl(), @applyDefaultAddToCartRequestDefaults(cartItems, options))
    .done(@publishCartChangedEvent)
    .fail(@showCartErrorMessage)

  publishCartChangedEvent: (data) ->
    EventBroker.publishEvent('cart-changed', data)

  addToVirtualCart: (cartItems = {}) ->
    cartItems = @transformCartItems(cartItems)
    options =
      headers:
        'Wb-VCart': utils.getVirtualCart()
    utils.ajaxRequest(@getCartResourceUrl(), @applyDefaultAddToCartRequestDefaults(cartItems, options))
    .done(@addToVirtualCartSuccess)
    .fail(@showCartErrorMessage)

  addToVirtualCartSuccess: (data) ->
    utils.saveVirtualCart(data.response)
    @publishCartChangedEvent(data)

  transformCartItems: (cartItems) ->
    (@transformCartItem(x) for x in cartItems)

  transformCartItem: (cartItem) ->
    skuProfileId: cartItem.id
    quantity: cartItem.quantity
    bits: cartItem.bits

  showCartErrorMessage: (xhr, textStatus)->
    error = utils.safeParse(xhr.responseText)
    messageText = "Error actualizando el registro #{textStatus}"
    message = if error then error.meta.message else messageText
    options = icon:'iconFont-candado', value: "Cerrar", title:'Error'
    utils.showMessageModal(message, options)

  doCartLoading: ->
    message = "Actualizando carrito ..."
    utils.showLoadingMessage(message)

  applyDefaultAddToCartRequestDefaults: (cartItems, options = {}) ->
    defaults =
      type: 'POST'
      dataType: 'json'
      data: JSON.stringify(cartItems: cartItems)
      context: @
      headers:
        'Accept-Language': 'es'
        'Content-Type': 'application/json;charset=utf-8'

    requestOptions = $.extend({}, defaults, options)
    requestOptions.headers = $.extend({}, defaults.headers, options.headers)
    requestOptions

# Prevent creating new properties and stuff.
Object.seal? cartUtils

module.exports = cartUtils
