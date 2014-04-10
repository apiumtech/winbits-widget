Controller = require 'controllers/base/controller'
mediator = Winbits.Chaplin.mediator

module.exports = class HomeController extends Controller

  index: ->
    console.log 'Home#index'
    if mediator.data.get('login-data')
      @redirectTo controller:'logged-in', action:'index'
    else
      @redirectTo controller:'not-logged-in', action:'index'
