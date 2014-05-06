Model = require 'models/base/model'
utils = require 'lib/utils'
env = Winbits.env
$ = Winbits.$


module.exports = class ShippingAddresses extends Model
  url: env.get('api-url') +  "/users/shipping-addresses.json"
  needsAuth: true

  initialize: ()->
    super

  parse: (data) ->
    addresses: data.response

  requestSaveNewShippingAddress: (formData, options)->
    defaults =
      type: "POST"
      contentType: "application/json"
      dataType: "json"
      data: JSON.stringify(formData)
      headers:
        "Accept-Language": "es"
        "WB-Api-Token": utils.getApiToken()

    utils.ajaxRequest(env.get('api-url') +  "/users/shipping-addresses.json",
        $.extend(defaults, options))

