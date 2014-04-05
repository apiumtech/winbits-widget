Controller = require "controllers/base/controller"
LoggedInView = require 'views/logged-in/logged-in-view'
LoggedInModel = require 'models/logged-in/logged-in'
utils = require 'lib/utils'
mediator = Winbits.Chaplin.mediator

module.exports = class LoggedInController extends Controller
  # Reusabilities persist stuff between controllers.
  # You may also persist models etc.
  beforeAction: ->
    super
    loginData = mediator.data.get 'login-data'
    if loginData
      @reuse 'logged-in', LoggedInView, model: new LoggedInModel loginData
    else
      @redirectTo 'home#index'

  index: ->
    console.log 'logged-in#index'
