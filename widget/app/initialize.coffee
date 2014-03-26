Application = require './application'
routes = require './routes'

# Initialize the application on DOM ready event.
Winbits.loadInterval = setInterval ->
  if Winbits.$(Winbits.config.widgetContainer).length
    clearInterval Winbits.loadInterval
    new Application {routes, controllerSuffix: '-controller'}
  #  Chaplin.utils.redirectTo controller:'home', action:'index'
, 10
