'use strict'
LoggedInController = require 'controllers/logged-in-controller'
TransferCartErrorsView = require 'views/transfer-cart-errors/transfer-cart-errors-view'
TransferCartErrors = require 'models/transfer-cart-errors/transfer-cart-errors'
utils = require 'lib/utils'
cartUtils = require 'lib/cart-utils'
_ = Winbits._
$ = Winbits.$
mediator = Winbits.Chaplin.mediator

module.exports = class TransferCartErrorsController extends LoggedInController

  beforeAction: ->
    super

  index: ()->
    params = mediator.data.get 'transfer-error'
    mediator.data.set 'transfer-error', {}
    unless($.isEmptyObject(params))
      @model = new TransferCartErrors params
      @view = new TransferCartErrorsView model: @model
    else
      utils.redirectToLoggedInHome()
