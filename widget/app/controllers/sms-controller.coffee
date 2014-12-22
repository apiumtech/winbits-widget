'use strict'

utils = require 'lib/utils'
LoggedInController = require 'controllers/logged-in-controller'
SmsView = require 'views/sms/sms-modal-view'
Sms = require 'models/sms/sms'

module.exports = class SmsController extends LoggedInController

  beforeAction: ->
    super

  index:->
    console.log 'sms#index'
    @model = new Sms()
    @view = new SmsView(model: @model)
