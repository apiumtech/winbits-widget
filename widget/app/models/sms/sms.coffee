utils = require 'lib/utils'
Model = require "models/base/model"
env = Winbits.env
$ = Winbits.$

module.exports = class Sms extends Model

  initialize: ->
    super

  requestSendMessage:(formData, options) ->
    console.log ["JSON form Data", JSON.stringify(formData), options]
#Todo check url in api documentation and headers
#    defaults =
#      type: "POST"
#      contentType: "application/json"
#      dataType: "json"
#      data: JSON.stringify(formData)
#      headers:
#        "Accept-Language": "es"
#    utils.ajaxRequest(env.get('api-url') + "/users/login.json",
#                      $.extend(defaults, options))
