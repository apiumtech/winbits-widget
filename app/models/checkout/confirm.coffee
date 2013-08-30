ChaplinModel = require 'chaplin/models/model'
config = require 'config'
module.exports = class Confirm extends ChaplinModel

  initialize: (attributes, option) ->
    super
    @url = config.apiUrl
    @subscribeEvent 'setConfirm', @set
    #@fetch success: (collection, response) ->
      #collection.resolve()
  parse: (response) ->
    response
