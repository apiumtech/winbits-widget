'use strict'

utils = require 'lib/utils'
LoggedInController = require 'controllers/logged-in-controller'
ActivationMobileView = require 'views/activation-mobile/activation-mobile-view'
Sms = require 'models/sms/sms'

module.exports = class ActivationMobileController extends LoggedInController

  beforeAction: ->
    super

  index:->
    console.log 'sms#index'
    @model = new Sms()
    @view = new ActivationMobileView(model: @model)
