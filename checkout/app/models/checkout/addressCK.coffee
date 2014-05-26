ChaplinModel = require 'chaplin/models/model'
config = require 'config'
util = require 'lib/util'
module.exports = class AddressCK extends ChaplinModel

  initialize: (attributes, option) ->
    super
    @url = config.apiUrl + "/users/shipping-addresses.json"
    @actualiza()

      #collection.resolve()
  parse: (response) ->
    addresses : response.response

  actualiza : ()->
    @fetch
      error: ->
        console.log "error cart",
      headers:{ 'Accept-Language': 'es', "WB-Api-Token": util.retrieveKey(config.apiTokenName)}
      success: ->
        console.log "success load Virtual cart"

  requestSaveNewShippingAddress: (formData, options)->
    defaults =
      type: "POST"
      contentType: "application/json"
      dataType: "json"
      data: JSON.stringify(formData)
      headers:
        "Accept-Language": "es"
        "WB-Api-Token": util.retrieveKey(config.apiTokenName)

    console.log JSON.stringify formData
        
    util.ajaxRequest(@url,
      Winbits.$.extend(defaults, options))

