Model = require 'models/base/model'
utils = require 'lib/utils'
$ = Winbits.$

module.exports = class Register extends Model

  initialize: (data)->
    super
    @set data

  requestRegisterUser:(formData, options) ->
    defaults =
      type: "POST"
      data:JSON.stringify(formData)

    utils.ajaxRequest(
      utils.getResourceURL("users/register.json"),
      $.extend(defaults, options)
    )

  requestResendConfirmationMail:(confirmURL)->
    defaults =
      dataType: "json"
      headers:
        "Accept-Language": "es"
    utils.ajaxRequest(
      utils.getResourceURL(confirmURL),defaults)