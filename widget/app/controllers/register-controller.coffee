NotLoggedInController = require 'controllers/not-logged-in-controller'
RegisterView = require 'views/register/register-view'
Register = require 'models/register/register'
env = Winbits.env

module.exports = class RegisterController extends NotLoggedInController

  index: ->
    console.log 'register#index'
    registerData =
      currentVerticalId: env.get 'current-vertical-id'
      activeVerticals: env.get 'verticals-data'
    @view = new RegisterView model: new Register registerData

