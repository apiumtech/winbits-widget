require = Winbits.require
utils = require 'lib/utils'
Model = require 'models/base/model'
_ = Winbits._
env = Winbits.env

module.exports = class CompleteRegister extends Model
  url: Winbits.env.get('api-url') + '/users/profile.json'
  needsAuth: true

  initialize: (loginData)->
    super
    @set @parse response: loginData

  parse: (data) ->
    profile = _.clone(data.response.profile)
    profile

  requestCompleteRegister:(data) ->
    utils.ajaxRequest(
        env.get('api-url') + "/users/profile.json",
      type: "PUT"
      contentType: "application/json"
      dataType: "json"
      data:JSON.stringify(data)
      headers:
        "Accept-Language": "es"
        "WB-Api-Token": utils.getApiToken()
    )
