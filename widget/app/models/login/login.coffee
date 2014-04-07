utils = require 'lib/utils'
env = Winbits.env

module.exports = class Login extends Chaplin.Model

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