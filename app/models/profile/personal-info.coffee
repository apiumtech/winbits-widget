ChaplinModel = require 'chaplin/models/model'
config = require 'config'
module.exports = class PersonalInfo extends ChaplinModel

  initialize: (attributes, option) ->
    super
    @url = config.apiUrl + "/users/profile.json"
    @subscribeEvent 'setPersonalInfo', @setProfileInfo

  setProfileInfo:(data) ->
    @set @loadDataProfile data
    @publishEvent 'renderEditProfile'

  parse: (response) ->
    response

  loadDataProfile: (data) ->
    model = {}
    model = data
    model

  set: (args) ->
    super