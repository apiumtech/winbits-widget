require = Winbits.require
utils = require 'lib/utils'
Model = require 'models/base/model'
mediator = Winbits.Chaplin.mediator
_ = Winbits._
$ = Winbits.$
env = Winbits.env

module.exports = class MyProfile extends Model
  url: Winbits.env.get('api-url') + '/users/profile.json'
  needsAuth: true

  initialize: (loginData = mediator.data.get 'login-data')->
    super
    @subscribeEvent 'layun', -> console.log ['Layún Aquí']
    @subscribeEvent 'profile-changed', @loadProfile
    @set(@parse response: loginData) if loginData

  parse: (data) ->
    profile = _.clone(data.response.profile)
    profile.email = data.response?.email
    profile

  loadProfile: (loginData) ->
    parsedData = @parse loginData
    @set parsedData

  requestUpdateProfile:(formData, options) ->
    defaults =
      type: "PUT"
      contentType: "application/json"
      dataType: "json"
      data:JSON.stringify(formData)
      headers:
        "Accept-Language": "es"
        "WB-Api-Token": utils.getApiToken()

    utils.ajaxRequest(
        env.get('api-url') + "/users/profile.json",
        $.extend(defaults, options)
    )

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
