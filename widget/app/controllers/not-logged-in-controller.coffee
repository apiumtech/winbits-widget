Controller = require "controllers/base/controller"
NotLoggedInView = require 'views/not-logged-in/not-logged-in-view'
utils = require 'lib/utils'
mediator = Winbits.Chaplin.mediator

module.exports = class NotLoggedInController extends Controller
  # Reusabilities persist stuff between controllers.
  # You may also persist models etc.
  beforeAction: ->
    super
    if not mediator.data.get 'login-data'
      console.log ['NOT LOGGED IN VIEW']
      @reuse 'not-logged-in', NotLoggedInView
    else
      @redirectTo 'home#index'

  index: ->
    console.log 'not-logged-in#index'
