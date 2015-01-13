'use strict'

utils = require 'lib/utils'
LoggedInController = require 'controllers/logged-in-controller'
SmsView = require 'views/sms/sms-modal-view'
Sms = require 'models/sms/sms'
mediator = Winbits.Chaplin.mediator

module.exports = class SmsController extends LoggedInController

  beforeAction: ->
    super

  index:->
    console.log 'sms#index'
    phone =  mediator.data.get('login-data').profile.phone
    @model = new Sms(phone: phone)
    @view = new SmsView(model: @model)
