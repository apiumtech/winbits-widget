ChaplinModel = require 'chaplin/models/model'
config = require 'config'
module.exports = class AddressCK extends ChaplinModel

  initialize: (attributes, option) ->
    super
    @url = config.apiUrl + "/affiliation/shipping-addresses"

    #@fetch success: (collection, response) ->
      #collection.resolve()
  parse: (response) ->
    response

