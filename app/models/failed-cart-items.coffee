ChaplinModel = require 'chaplin/models/model'

module.exports = class FailedCartItems extends ChaplinModel

  initialize: () ->
    super
    @subscribeEvent 'cartItemsFailed', @updateModel

  updateModel: (data) ->
    @set failedCartItems: data