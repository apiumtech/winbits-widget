Controller = require "controllers/base/controller"
NotLoggedInView = require 'views/not-logged-in/not-logged-in-view'
#NotLoggedIn = require 'models/not-logged-in/not-logged-in'
utils = require 'lib/utils'
mediator = Winbits.Chaplin.mediator
$ = Winbits.$
module.exports = class NotLoggedInController extends Controller
  # Reusabilities persist stuff between controllers.
  # You may also persist models etc.
  beforeAction: ->
    super
    if not mediator.data.get 'login-data'
      @reuse 'not-logged-in',  NotLoggedInView
    else
      @redirectTo 'home#index'

  index: ->
    console.log 'not-logged-in#index'
