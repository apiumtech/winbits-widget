utils = require 'lib/utils'
Model = require "models/base/model"
env = Winbits.env
mediator = Winbits.Chaplin.mediator
$ = Winbits.$

module.exports = class verifyMobile extends Model

  initialize: () ->
    super

  sendCodeForActivationMobile:(formData, options) ->
    loginData = mediator.data.get('login-data')
    $.extend(formData, mobile: loginData.profile.phone)
    defaults =
      type: "POST"
      contentType: "application/json"
      dataType: "json"
      data: JSON.stringify(formData)
      headers:
         "Accept-Language": "es",
         "WB-Api-Token": utils.getApiToken()

    utils.ajaxRequest(env.get('api-url') + "/users/activate-mobile",
    $.extend(defaults, options))

  reSendCodeToClient:(options) ->
    loginData = mediator.data.get('login-data')
    defaults =
      type: "POST"
      contentType: "application/json"
      dataType: "json"
      data: JSON.stringify(mobile: loginData.profile.phone,carrier:'')
      headers:
        "Accept-Language": "es",
        "WB-Api-Token": utils.getApiToken()
    utils.ajaxRequest(env.get('api-url') + "/users/send-sms",
      $.extend(defaults, options))