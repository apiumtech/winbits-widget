'use strict'

utils = require 'lib/utils'
trackingUtils = require 'lib/tracking-utils'
mediator = Chaplin.mediator
$ = Winbits.$
_ = Winbits._
env = Winbits.env

addToVirtualCart: (cartItems = {}) ->
  cartItemsToRequest = @transformVirtualCartItems(cartItems)
  cartVirtualItems = @transformCartItems(cartItems)
  options =
    headers:
      'Accept-Language': 'es'
      'Content-Type': 'application/json;charset=utf-8'
      'Wb-VCart': utils.getCartItemsToVirtualCart()
  options = @applyAddToCartRequestDefaults(cartItemsToRequest, options)
  utils.ajaxRequest(@getCartResourceUrl(), options)
  .done((data)-> @addToVirtualCartSuccess(data, cartVirtualItems))
  .fail(@showCartErrorMessage)