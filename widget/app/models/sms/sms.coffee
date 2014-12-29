utils = require 'lib/utils'
Model = require "models/base/model"
env = Winbits.env
$ = Winbits.$

module.exports = class Sms extends Model

  initialize: ->
    super

  requestSendMessage:(formData, options) ->
    defaults =
      type: "GET"
      contentType: "application/json"
      dataType: "json"
      headers:
        "Accept-Language": "es"
    utils.ajaxRequest(env.get('api-url') + "/users/send-sms/#{formData.cellphone}",
                      $.extend(defaults, options))
