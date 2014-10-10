'use strict'
LoggedInController = require 'controllers/logged-in-controller'
OldOrdersHistoryView = require 'views/old-orders-history/old-orders-history-view'
OldOrdersHistory = require 'models/old-orders-history/old-orders-history'
utils = require 'lib/utils'

module.exports = class OldOrdersHistoryController extends LoggedInController

  beforeAction: ->
    super

  index: ->
    @model = new OldOrdersHistory
    @view = new OldOrdersHistoryView  model: @model