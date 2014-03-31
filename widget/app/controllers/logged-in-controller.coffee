Controller = require "controllers/base/controller"
LoggedInView = require 'views/logged-in/logged-in-view'
LoggedInModel = require 'models/logged-in/logged-in'

module.exports = class LoggedInController extends Controller
  # Reusabilities persist stuff between controllers.
  # You may also persist models etc.
  beforeAction: (params)->
    super
    model = new LoggedInModel(params)
    @reuse 'logged-in', LoggedInView, model: model

  index: ->
    console.log 'logged-in#index'
