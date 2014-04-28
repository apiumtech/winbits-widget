Application = require './application'
routes = require './routes'
cartUtils = require 'lib/cart-utils'
utils = require 'lib/utils'
mediator = Winbits.Chaplin.mediator

mediator.data = (->
  # Add additional application-specific properties and methods
  # e.g. Chaplin.mediator.prop = null
  data =
    'login-data': Winbits.env.get 'login-data'
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

Winbits.addToCart = ->
  fn = if utils.isLoggedIn() then cartUtils.addToUserCart else cartUtils.addToVirtualCart
  fn.apply(Winbits, arguments)

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
