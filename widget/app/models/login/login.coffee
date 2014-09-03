utils = require 'lib/utils'
Model = require "models/base/model"
env = Winbits.env
$ = Winbits.$

module.exports = class Login extends Model

  initialize: ->
    super

  requestLogin:(formData, options) ->
    defaults =
      type: "POST"
      contentType: "application/json"
      dataType: "json"
      data: JSON.stringify(formData)
      headers:
        "Accept-Language": "es"
    utils.ajaxRequest(env.get('api-url') + "/users/login.json",
                      $.extend(defaults, options))