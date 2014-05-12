Model = require 'models/base/model'
utils = require 'lib/utils'
env = Winbits.env
$ = Winbits.$
_ = Winbits._


module.exports = class EditShippingAddresses extends Model

  initialize: ()->
    super

  parse: (data) ->
    address: data

  requestSaveEditShippingAddress: (itemId,formData, options)->
    defaults =
      type: "PUT"
      contentType: "application/json"
      dataType: "json"
      data: JSON.stringify(formData)
      headers:
        "Accept-Language": "es"
        "WB-Api-Token": utils.getApiToken()

    utils.ajaxRequest(env.get('api-url') +  "/users/shipping-addresses/#{itemId}.json",
      $.extend(defaults, options))