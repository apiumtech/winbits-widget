Model = require 'models/base/model'
utils = require 'lib/utils'
env = Winbits.env
$ = Winbits.$


module.exports = class ShippingAddresses extends Model

  initialize: ()->
    super

  parse: (response) ->
    response

  requestGetShippingAddresses:(options) ->
    defaults =
      type: "GET"
      contentType: "application/json"
      dataType: "json"
      headers:
        "Accept-Language": "es"
        "WB-Api-Token": Winbits.env.get('api-token-name')

    utils.ajaxRequest(
      env.get('api-url') +  "/users/shipping-addresses.json",
      $.extend(defaults, options)
    )

  set: (args) ->
    super