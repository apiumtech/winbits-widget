LoggedInController = require 'controllers/logged-in-controller'
YourBitsView = require 'views/your-bits-history/your-bits-history-view'
YourBitsModel = require 'models/your-bits/your-bits'
utils = require 'lib/utils'

module.exports = class YourBitsController extends LoggedInController

  beforeAction: ->
    super

  index: ->
    console.log 'yourBits#index'
    @model = new YourBitsModel
    @view = new YourBitsView  model: @model
