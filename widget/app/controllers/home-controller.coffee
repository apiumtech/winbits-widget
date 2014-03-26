Controller = require 'controllers/base/controller'

module.exports = class HomeController extends Controller

  index: ->
    console.log 'Home#index'
    if localStorage['token']
      Chaplin.utils.redirectTo controller:'logged-in', action:'index'
    else
      Chaplin.utils.redirectTo controller:'not-logged-in', action:'index'
