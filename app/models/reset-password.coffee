ChaplinModel = require 'chaplin/models/model'

module.exports = class ResetPassword extends ChaplinModel

  initialize: (attributes, option) ->
    super
    @subscribeEvent 'updateResetModel', @updateModel

  updateModel: (data) ->
    @set data