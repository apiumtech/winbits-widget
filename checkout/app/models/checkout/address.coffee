ChaplinModel = require 'chaplin/models/model'
config = require 'config'
util = require 'lib/util'
module.exports = class Address extends ChaplinModel

  initialize: (attributes, option) ->
    super
    @url = config.apiUrl + "/users/shipping-addresses.json"

  requestSaveNewShippingAddress: (formData, options)->
    defaults =
      type: "POST"
      contentType: "application/json"
      dataType: "json"
      data: JSON.stringify(formData)
      headers:
        "Accept-Language": "es"
        "WB-Api-Token": util.retrieveKey(config.apiTokenName)

    util.ajaxRequest(@url,
      Winbits.$.extend(defaults, options))

  requestSaveEditShippingAddress: (itemId,formData, options)->
    defaults =
      type: "PUT"
      contentType: "application/json"
      dataType: "json"
      data: JSON.stringify(formData)
      headers:
        "Accept-Language": "es"
        "WB-Api-Token": util.retrieveKey(config.apiTokenName)

    util.ajaxRequest(Winbits.env.get('api-url') +  "/users/shipping-addresses/#{itemId}.json",
      Winbits.$.extend(defaults, options))

