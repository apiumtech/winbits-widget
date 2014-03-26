Controller = require "controllers/base/controller"
NotLoggedInView = require 'views/not-logged-in/not-logged-in-view'

module.exports = class NotLoggedInController extends Controller
  # Reusabilities persist stuff between controllers.
  # You may also persist models etc.
  beforeAction: ->
    super
    @reuse 'not-login', NotLoggedInView

  index: ->
    console.log 'not-logged-in#index'