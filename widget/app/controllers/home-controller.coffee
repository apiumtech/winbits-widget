Controller = require 'controllers/base/controller'
mediator = Winbits.Chaplin.mediator
utils = require 'lib/utils'
env = Winbits.env

module.exports = class HomeController extends Controller

  index: ->
    console.log 'Home#index'

    if mediator.data.get('login-data')
      utils.redirectTo controller:'logged-in', action:'index'
    else
      if env.get('current-vertical').name is "Promociones"
        window.location.href = env.get('home-url')
      else
        utils.redirectTo controller:'not-logged-in', action:'index'
