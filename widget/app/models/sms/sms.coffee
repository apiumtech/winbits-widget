utils = require 'lib/utils'
Model = require "models/base/model"
env = Winbits.env
mediator = Winbits.Chaplin.mediator
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
        "WB-Api-Token": utils.getApiToken()
    utils.ajaxRequest(env.get('api-url') + "/users/send-sms/#{formData.cellphone}",
                      $.extend(defaults, options))

  sendCodeForActivationMobile:(formData, options) ->
    loginData = mediator.data.get('login-data')
    $.extend(formData, cellphone: loginData.profile.phone)
    defaults =
      contentType: "application/json"
      dataType: "json"
      data: JSON.stringify(formData)
      headers:
        "Accept-Language": "es",
        "WB-Api-Token": utils.getApiToken()

    utils.ajaxRequest(env.get('api-url') + "/users/activate-mobile/#{formData.cellphone}/#{formData.code}",
      $.extend(defaults, options))