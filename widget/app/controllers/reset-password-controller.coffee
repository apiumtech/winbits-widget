NotLoggedInController = require 'controllers/not-logged-in-controller'
ResetPassword =  require 'models/reset-password/reset-password'
ResetPasswordView = require 'views/reset-password/reset-password-view'


module.exports = class ResetPasswordController extends NotLoggedInController

  index: (params) ->
    console.log 'reset-password#index'
    model = new ResetPassword params  #setting salt param in model
    @view = new ResetPasswordView  model: model

