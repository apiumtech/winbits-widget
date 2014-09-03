Controller = require 'controllers/base/controller'
mediator = Winbits.Chaplin.mediator
utils = require 'lib/utils'

module.exports = class HomeController extends Controller

  index: ->
    console.log 'Home#index'
    if mediator.data.get('login-data')
      utils.redirectTo controller:'logged-in', action:'index'
    else
      utils.redirectTo controller:'not-logged-in', action:'index'
