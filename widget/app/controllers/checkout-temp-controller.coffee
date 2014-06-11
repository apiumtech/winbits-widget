'use strict'
LoggedInController = require 'controllers/logged-in-controller'
CheckoutTempView = require 'views/checkout-temp/checkout-temp-view'
CheckoutTemp = require 'models/checkout-temp/checkout-temp'
utils = require 'lib/utils'

module.exports = class CheckoutController extends LoggedInController

  beforeAction: ->
    super

  index: (request)->
    @model = new CheckoutTemp request
    @view = new CheckoutTemp  model: @model