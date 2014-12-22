'use strict'

utils = require 'lib/utils'
LoggedInController = require 'controllers/logged-in-controller'

module.exports = class SmsController extends LoggedInController

  beforeAction: ->
    super

  index:->
    console.log 'sms#index'
    alert "ENTRY IN SMS CONTROLLER"


