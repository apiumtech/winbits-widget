ChaplinModel = require 'chaplin/models/model'
config = require 'config'
module.exports = class RegisterFb extends ChaplinModel

  initialize: (attributes, option) ->
    super
    @subscribeEvent 'setRegisterFb', @set

  #@fetch success: (collection, response) ->
  #collection.resolve()
  parse: (response) ->
    response

