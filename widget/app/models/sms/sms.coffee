utils = require 'lib/utils'
Model = require "models/base/model"
env = Winbits.env
$ = Winbits.$

module.exports = class Sms extends Model

  initialize: ->
    super

  requestSendMessage:(formData, options) ->
    defaults =
      type: "POST"
      contentType: "application/json"
      dataType: "json"
      data: JSON.stringify(mobile: formData.mobile, carrier:formData.carrier)
      headers:
        "Accept-Language": "es",
        "WB-Api-Token": utils.getApiToken()
    utils.ajaxRequest(env.get('api-url') + "/users/send-sms",
                      $.extend(defaults, options))

  requestActivateMobile:(formData, options)->
    defaults =
      type: "POST"
      contentType: "application/json"
      dataType: "json"
      data: JSON.stringify(mobile: @get('mobile'), code: formData.code)
      headers:
        "Accept-Language": "es",
        "WB-Api-Token": utils.getApiToken()
    utils.ajaxRequest(env.get('api-url') + "/users/activate-mobile",
                      $.extend(defaults, options))
