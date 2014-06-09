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
    console.log ["params",params]

    warnings = params.cartDetails.map (cartDetail) -> cartDetail.warnings
    @model = new TransferCartErrors warnings
    @view = new TransferCartErrorsView model: @model
