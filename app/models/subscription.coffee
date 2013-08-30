ChaplinModel = require 'chaplin/models/model'
config = require 'config'
module.exports = class Subscription extends ChaplinModel

  initialize: (attributes, option) ->
    super
    @subscribeEvent 'setSubscription', @set

  parse: (response) ->
    response

