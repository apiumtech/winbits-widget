ChaplinModel = require 'chaplin/models/model'
config = require 'config'
module.exports = class Payments extends ChaplinModel

  initialize: (attributes, option) ->
    super
    @subscribeEvent "orderBitsUpdated", @updateBitsParser

    #@fetch success: (collection, response) ->
      #collection.resolve()
  parse: (response) ->
    response

  updateBitsParser: (response) ->
      @set methods:response.paymentMethods
