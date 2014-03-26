Controller = require "controllers/base/controller"
LoggedInView = require 'views/logged-in/logged-in-view'

module.exports = class LoggedInController extends Controller
  # Reusabilities persist stuff between controllers.
  # You may also persist models etc.
  beforeAction: ->
    super
    @reuse 'header', LoggedInView

  index: ->
    console.log 'logged-in#index'
