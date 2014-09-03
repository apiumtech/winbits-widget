NotLoggedInController = require 'controllers/not-logged-in-controller'
RecoverPasswordModel =  require 'models/recover-password/recover-password'
RecoverPasswordView = require 'views/recover-password/recover-password-view'
env = Winbits.env

module.exports = class RecoverPasswordController extends NotLoggedInController

  index: ->
    console.log 'recover-password#index'
#    registerData =
#      currentVerticalId: env.get 'current-vertical-id'
#      activeVerticals: env.get 'verticals-data'
##    @model = new Register registerData
    model = new RecoverPasswordModel
    @view = new RecoverPasswordView model: model

