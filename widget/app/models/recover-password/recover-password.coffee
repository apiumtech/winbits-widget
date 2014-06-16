Model = require 'models/base/model'
utils = require 'lib/utils'
env = Winbits.env
$ = Winbits.$


module.exports = class RecoverPassword extends Model

  initialize: (data)->
    super
    @set data

  requestRecoverPassword:(formData, options) ->
    defaults =
      data: JSON.stringify(formData)
      type: "POST"
      contentType: "application/json"
      dataType: "json"
      xhrFields:
        withCredentials: true
      headers:
        "Accept-Language": "es"
    utils.ajaxRequest(
      env.get('api-url') + "/users/password/recover.json",
      $.extend(defaults, options)
    )

