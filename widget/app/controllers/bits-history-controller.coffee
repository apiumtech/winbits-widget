LoggedInController = require 'controllers/logged-in-controller'
BitsHistoryView = require 'views/bits-history/bits-history-view'
BitsHistory = require 'models/bits-history/bits-history'
utils = require 'lib/utils'

module.exports = class YourBitsController extends LoggedInController

  beforeAction: ->
    super

  index: ->
    console.log 'yourBits#index'
    @model = new BitsHistory
    @view = new BitsHistoryView  model: @model
