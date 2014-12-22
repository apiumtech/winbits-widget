'use strict'

utils = require 'lib/utils'
LoggedInController = require 'controllers/logged-in-controller'
ActivationMobileView = require 'views/activation-mobile/activation-mobile-view'
Sms = require 'models/sms/sms'

module.exports = class ActivationMobileController extends LoggedInController

  beforeAction: ->
    super

  index:()->
    console.log 'sms#index'
    data= Winbits.Chaplin.mediator.data.get('activation-data')
    @model = new Sms(data)
    @view = new ActivationMobileView(model: @model)
