'use strict'
LoggedInController = require 'controllers/logged-in-controller'
TransferCartErrorsView = require 'views/transfer-cart-errors/transfer-cart-errors-view'
TransferCartErrors = require 'models/transfer-cart-errors/transfer-cart-errors'
utils = require 'lib/utils'
cartUtils = require 'lib/cart-utils'
_ = Winbits._

module.exports = class TransferCartErrorsController extends LoggedInController

  beforeAction: ->
    super

  index: (params)->
    @model = new TransferCartErrors
    @model.initialize(params)
    @view = new TransferCartErrorsView model: @model
