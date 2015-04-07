NotLoggedInController = require 'controllers/not-logged-in-controller'
RegisterView = require 'views/register/register-view'
Register = require 'models/register/register'
Utils = require 'lib/utils'
env = Winbits.env

module.exports = class RegisterController extends NotLoggedInController

  index: ->
    console.log 'register#index'
    if(!Utils.isLoggedIn())
      registerData =
        currentVerticalId: env.get 'current-vertical-id'
        activeVerticals: env.get 'verticals-data'
      @model = new Register registerData
      @view = new RegisterView model: @model
    else
      utils.redirectToNotLoggedInHome()
