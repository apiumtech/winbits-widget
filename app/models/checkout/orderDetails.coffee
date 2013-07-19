ChaplinModel = require 'chaplin/models/model'
config = require 'config'
module.exports = class OrderDetails extends ChaplinModel

  initialize: (attributes, option) ->
    super

  parse: (response) ->
    response

