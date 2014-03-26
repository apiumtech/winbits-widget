Application = require './application'
routes = require './routes'

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
