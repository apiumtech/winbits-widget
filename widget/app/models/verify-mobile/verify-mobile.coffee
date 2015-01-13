utils = require 'lib/utils'
Model = require "models/base/model"
env = Winbits.env
$ = Winbits.$

module.exports = class verifyMobile extends Model

  initialize: () ->
    super


  sendCodeForActivationMobile:(formData, options) ->
    $.extend(formData, cellphone: @get 'mobile')
    defaults =
      contentType: "application/json"
      dataType: "json"
      data: JSON.stringify(formData)
      headers:
         "Accept-Language": "es",
         "WB-Api-Token": utils.getApiToken()

    utils.ajaxRequest(env.get('api-url') + "/users/activate-mobile",
    $.extend(defaults, options))

  reSendCodeToClient:(options) ->
    defaults =
      contentType: "application/json"
      dataType: "json"
      data: ""
      headers:
        "Accept-Language": "es",
        "WB-Api-Token": utils.getApiToken()
    utils.ajaxRequest(env.get('api-url') + "/users/send-sms/#{@get('mobile')}",
      $.extend(defaults, options))