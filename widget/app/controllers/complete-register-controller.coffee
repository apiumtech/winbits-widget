Controller = require "controllers/logged-in-controller"
CompleteRegisterView = require 'views/complete-register/complete-register-view'
CompleteRegisterModel = require 'models/complete-register/complete-register'
$ = Winbits.$
mediator = Winbits.Chaplin.mediator

module.exports = class CompleteRegisterController extends Controller

  beforeAction: ->
    console.log 'complete-register'
    super

  index: ->
    console.log 'complete-register#index'

    data = mediator.data.get('login-data')
    @model = new CompleteRegisterModel  data
    @view = new CompleteRegisterView model:@model
