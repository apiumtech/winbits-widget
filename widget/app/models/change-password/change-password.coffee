require = Winbits.require
utils = require 'lib/utils'
Model = require 'models/base/model'
mediator = Winbits.Chaplin.mediator
_ = Winbits._
$ = Winbits.$
env = Winbits.env

module.exports = class ChangePassword extends Model
  needsAuth: true

  requestChangePassword:(formData, options) ->
    defaults =
      type: "PUT"
      contentType: "application/json"
      dataType: "json"
      data:JSON.stringify(formData)
      headers:
        "Accept-Language": "es"
        "WB-Api-Token": utils.getApiToken()

    utils.ajaxRequest(
        env.get('api-url') + "/users/change-password.json",
        $.extend(defaults, options)
    )