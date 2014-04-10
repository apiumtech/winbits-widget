Application = require './application'
routes = require './routes'
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

if Winbits.env.get 'optimized'
  # Initialize the application on DOM ready event.
  Winbits.loadInterval = setInterval ->
    if Winbits.$(Winbits.env.get 'widget-container').length
      clearInterval Winbits.loadInterval
      delete Winbits.loadInterval
      new Application routes: routes, controllerSuffix: '-controller', pushState: false
  , 5
else
  Winbits.$ ->
    new Application routes: routes, controllerSuffix: '-controller', pushState: false
