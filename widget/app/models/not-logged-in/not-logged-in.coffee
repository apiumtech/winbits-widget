utils = require 'lib/utils'
Model = require "models/base/model"
env = Winbits.env
$ = Winbits.$

module.exports = class NotLoggedIn extends Model

  initialize: ->
    super

  requestExpressFacebookLogin:(formData, options) ->
    defaults =
      type: "POST"
      data: JSON.stringify(formData)
    utils.ajaxRequest(env.get('api-url') + "/users/express-facebook-login.json",
        $.extend(defaults, options))