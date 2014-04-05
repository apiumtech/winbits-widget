utils = require 'lib/utils'
loginUtil = require 'lib/login-utils'
env = Winbits.env

module.exports = class LoggedIn extends Chaplin.Model

   initialize: ->
     super

   requestLogout: ->
     utils.ajaxRequest(
       env.get('api-url') + "/users/logout.json",
       type: "POST"
       contentType: "application/json"
       dataType: "json"
       headers:
         "Accept-Language": "es"
         "WB-Api-Token": utils.getApiToken()
     )
