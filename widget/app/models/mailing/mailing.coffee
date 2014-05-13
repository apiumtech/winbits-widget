utils = require 'lib/utils'
Model = require "models/base/model"
env = Winbits.env
$ = Winbits.$

module.exports = class Mailing extends Model

  initialize: ->
    super


  requestUpdateSubscriptions: (data, options) ->
    defaults =
      type: "PUT"
      contentType: "application/json"
      dataType: "json"
      data: JSON.stringify(data)
      headers:
        "Accept-Language": "es"
        "WB-Api-Token": utils.getApiToken()

    utils.ajaxRequest(env.get('api-url') +  "/users/updateSubscriptions.json",
      $.extend(defaults, options))