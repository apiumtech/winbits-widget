Controller = require "controllers/logged-in-controller"
CompleteRegisterView = require 'views/complete-register/complete-register-view'
CompleteRegister = require 'models/complete-register/complete-register'
MyProfile = require 'models/my-profile/my-profile'
$ = Winbits.$

module.exports = class CompleteRegisterController extends Controller

  beforeAction: ->
    super
    console.log 'complete-register'

  index: ->
    console.log 'complete-register#index'
    @model = new CompleteRegister
    @view = new CompleteRegisterView model: @model
