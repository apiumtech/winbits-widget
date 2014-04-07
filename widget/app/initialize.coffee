Application = require './application'
routes = require './routes'
mediator = Winbits.Chaplin.mediator

mediator.data = (->
  # Add additional application-specific properties and methods
  # e.g. Chaplin.mediator.prop = null
  persistentData = rpc: Winbits.env.get 'rpc'
  data = Winbits.$.extend {'login-data': Winbits.env.get('login-data')}, persistentData
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
    data = Winbits.$.extend {}, persistentData
    return
  }
)()

# Initialize the application on DOM ready event.
# Winbits.loadInterval = setInterval ->
#   if Winbits.$(Winbits.config.widgetContainer).length
#     clearInterval Winbits.loadInterval
#     delete Winbits.loadInterval
#     new Application routes: routes, controllerSuffix: '-controller', pushState: false
#   #  Chaplin.utils.redirectTo controller:'home', action:'index'
# , 10

Winbits.$ ->
  new Application routes: routes, controllerSuffix: '-controller', pushState: false
  #  Chaplin.utils.redirectTo controller:'home', action:'index'
