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
    $.extend(formData, cellphone: loginData.profile.phone)
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
      contentType: "application/json"
      dataType: "json"
      data: ""
      headers:
        "Accept-Language": "es",
        "WB-Api-Token": utils.getApiToken()
    utils.ajaxRequest(env.get('api-url') + "/users/send-sms/#{loginData.profile.phone}",
      $.extend(defaults, options))