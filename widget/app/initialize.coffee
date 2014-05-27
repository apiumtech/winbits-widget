Application = require './application'
routes = require './routes'
cartUtils = require 'lib/cart-utils'
wishListUtils = require 'lib/favorite-utils'
utils = require 'lib/utils'
mediator = Winbits.Chaplin.mediator

mediator.data = (->
  # Add additional application-specific properties and methods
  # e.g. Chaplin.mediator.prop = null
  data =
    'login-data': Winbits.env.get 'login-data'
    'virtual-cart': Winbits.env.get('virtual-cart')
  {
  get: (property)->
    data[property]
  set: (property, value)->
    data[property] = value
    return
  delete: (property) ->
    value = data[property]
    delete data[property]
    value
  clear: ->
    data = {}
    return
  }
)()

Winbits.addToCart = (cartItems) ->
  cartItems = if Winbits.$.isArray(cartItems) then cartItems else [cartItems]
  fn = if utils.isLoggedIn() then cartUtils.addToUserCart else cartUtils.addToVirtualCart
  fn.call(cartUtils, cartItems)

Winbits.addToWishList = (options ) ->
  fn = if utils.isLoggedIn() then wishListUtils.addToWishList
  fn.call(wishListUtils,options)

Winbits.deleteFromWishList = (options) ->
  fn = if utils.isLoggedIn() then wishListUtils.deleteFromWishList
  fn.call(wishListUtils,options)

appConfig =
  controllerSuffix: '-controller'
  pushState: no

appConfig.routes = routes unless window.wbTestEnv
if Winbits.env.get 'optimized'
  # Initialize the application on DOM ready event.
  Winbits.loadInterval = setInterval ->
    if Winbits.$(Winbits.env.get 'widget-container').length
      clearInterval Winbits.loadInterval
      delete Winbits.loadInterval
      new Application appConfig
  , 5
else
  Winbits.$ ->
    new Application appConfig
