NotLoggedInController = require 'controllers/not-logged-in-controller'
#RecoverPasswordModel =  require 'models/recover-password/recover-password'
ResetPasswordView = require 'views/reset-password/reset-password-view'


module.exports = class ResetPasswordController extends NotLoggedInController

  index: ->
    console.log 'reset-password#index'
#    model = new RecoverPasswordModel
    @view = new ResetPasswordView #model: model

