ChaplinModel = require 'chaplin/models/model'
config = require 'config'
util = require 'lib/util'
module.exports = class AddressCK extends ChaplinModel

  initialize: (attributes, option) ->
    super
    @url = config.apiUrl + "/affiliation/shipping-addresses"
    @actualiza()

      #collection.resolve()
  parse: (response) ->
    addresses : response.response

  actualiza : ()->
    @fetch
      error: ->
        console.log "error cart",
      headers:{ 'Accept-Language': 'es', "WB-Api-Token": util.getCookie(config.apiTokenName)}
      success: ->
        console.log "success load Virtual cart"

