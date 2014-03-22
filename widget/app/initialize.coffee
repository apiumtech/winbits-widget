Application = require './application'
routes = require './routes'

# Initialize the application on DOM ready event.
$ ->
  new Application {routes, controllerSuffix: '-controller'}
#  Chaplin.utils.redirectTo controller:'home', action:'index'
