'use strict'

utils = require 'lib/utils'
LoggedInController = require 'controllers/logged-in-controller'
SmsView = require 'views/sms/sms-modal-view'

module.exports = class SmsController extends LoggedInController

  beforeAction: ->
    super

  index:->
    console.log 'sms#index'
    @view = new SmsView()
