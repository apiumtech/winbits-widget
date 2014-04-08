NotLoggedInController = require 'controllers/not-logged-in-controller'
RecoverPasswordView = require 'views/recover-password/recover-password-view'
#RecoverPassword = require 'models/register/register'
env = Winbits.env

module.exports = class RegisterController extends NotLoggedInController

  index: ->
    console.log 'recover-password#index'
    registerData =
      currentVerticalId: env.get 'current-vertical-id'
      activeVerticals: env.get 'verticals-data'
#    @model = new Register registerData
    @view = new RecoverPasswordView

