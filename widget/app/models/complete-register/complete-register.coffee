require = Winbits.require
utils = require 'lib/utils'
Model = require 'models/base/model'
_ = Winbits._
$ = Winbits.$
env = Winbits.env

module.exports = class CompleteRegister extends Model
  url: Winbits.env.get('api-url') + '/users/profile.json'
  needsAuth: true

  initialize: (loginData)->
    super
    parseData = @parse response: loginData
    @set parseData

  parse: (data) ->
    profile = _.clone(data.response.profile)
    profile.currentVerticalId = env.get 'current-vertical-id'
    profile.activeVerticals = env.get 'verticals-data'
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
