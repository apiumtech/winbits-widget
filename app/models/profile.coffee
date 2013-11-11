ChaplinModel = require 'chaplin/models/model'
config = require 'config'
module.exports = class Profile extends ChaplinModel

  initialize: (attributes, option) ->
    super
    @url = config.apiUrl + "/affiliation/profile.json"
    @subscribeEvent 'setProfile', @set

  parse: (response) ->
    response
