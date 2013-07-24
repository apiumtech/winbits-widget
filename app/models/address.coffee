ChaplinModel = require 'chaplin/models/model'
config = require 'config'
module.exports = class Address extends ChaplinModel

  initialize: (attributes, option) ->
    super
    @url = config.apiUrl + "/affiliation/profile.json"
    @subscribeEvent 'setAddress', @set

    #@fetch success: (collection, response) ->
      #collection.resolve()
  parse: (response) ->
    response
  set: (args) ->
    super
    console.log ["wee", args]

