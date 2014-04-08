Controller = require "controllers/logged-in-controller"
CompleteRegisterView = require 'views/complete-register/complete-register-view'
CompleteRegisterModel = require 'models/complete-register/complete-register'
$ = Winbits.$
mediator = Winbits.Chaplin.mediator

module.exports = class CompleteRegisterController extends Controller

  beforeAction: (params)->
    console.log 'complete-register'
    super

  index: ->
    console.log 'complete-register#index'
    data = $.extend({}, mediator.data.get('login-data'), {currentVerticalId: env.get 'current-vertical-id', activeVerticals: env.get 'verticals-data'})
    @model = new CompleteRegisterModel data
    @view = new CompleteRegisterView model:@model
