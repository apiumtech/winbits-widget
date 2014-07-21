'use strict'
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
      data:JSON.stringify(formData)
      headers:
        "Accept-Language": "es"
        "WB-Api-Token": utils.getApiToken()

    utils.ajaxRequest(
        utils.getResourceURL("users/profile.json"),
        $.extend(defaults, options)
    )

  fieldIsRequired: (fieldName)->
    isRequired = no
    if mediator.data.get('login-data').profile.completeRegister
      if @get fieldName
        isRequired = yes
    isRequired
