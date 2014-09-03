Model = require 'models/base/model'
utils = require 'lib/utils'
env = Winbits.env
$ = Winbits.$


module.exports = class RecoverPassword extends Model

  initialize: ()->
    super

  requestResetPassword:(formData, options) ->
    defaults =
      data: JSON.stringify(formData)
      type: "POST"
      contentType: "application/json"
      dataType: "json"
      xhrFields:
        withCredentials: true
      headers:
        "Accept-Language": "es"
        "WB-Api-Token": Winbits.env.get('api-token-name')

    utils.ajaxRequest(
      env.get('api-url') +  "/users/password/reset.json",
      $.extend(defaults, options)
    )

