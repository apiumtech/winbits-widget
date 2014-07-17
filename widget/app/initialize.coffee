Application = require './application'
routes = require './routes'
cartUtils = require 'lib/cart-utils'
wishListUtils = require 'lib/favorite-utils'
skuProfileUtils = require 'lib/sku-profile-utils'
socialUtils = require 'lib/social-utils'
utils = require 'lib/utils'
trackingUtils = require 'lib/tracking-utils'
mediator = Winbits.Chaplin.mediator
EventBroker = Winbits.Chaplin.EventBroker

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
# mediator.data.set('virtual-cart', Winbits.env.get('virtual-cart'))

Winbits.addToCart = (cartItems) ->
  cartItems = if Winbits.$.isArray(cartItems) then cartItems else [cartItems]
  fnName = if utils.isLoggedIn() then 'addToUserCart' else 'addToVirtualCart'
  cartUtils[fnName].call(cartUtils, cartItems)

Winbits.addToWishList = (options ) ->
  fn = if utils.isLoggedIn() then wishListUtils.addToWishList
  fn.call(wishListUtils,options)

Winbits.deleteFromWishList = (options) ->
  fn = if utils.isLoggedIn() then wishListUtils.deleteFromWishList
  fn.call(wishListUtils,options)

Winbits.getSkuProfileInfo= (options) ->
  fn = skuProfileUtils.getSkuProfileInfo
  fn.call(skuProfileUtils, options)

Winbits.getSkuProfilesInfo= (options) ->
  fn = skuProfileUtils.getSkuProfilesInfo
  fn.call(skuProfileUtils, options)

Winbits.share= (options) ->
  fn = socialUtils.share
  fn.call(socialUtils, options)

Winbits.tweet= (options) ->
  fn = socialUtils.tweet
  fn.call(socialUtils, options)

Winbits.like= (options) ->
  fn = socialUtils.like
  fn.call(socialUtils, options)

Winbits.execute= (queryString) ->
  params = utils.parseQueryString(queryString)
  EventBroker.publishEvent params.code, params

# Look for UTMs and save it in each page hit
trackingUtils.saveUtmsIfAvailable()

appConfig =
  controllerSuffix: '-controller'
  pushState: no

appConfig.routes = routes unless window.wbTestEnv
if Winbits.env.get('optimized') and not Winbits.isCrapBrowser
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
