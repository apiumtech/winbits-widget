ChaplinModel = require 'chaplin/models/model'
config = require 'config'
module.exports = class Resume extends ChaplinModel

  initialize: (attributes, option) ->
    super
    @subscribeEvent 'updateResumeModel', @updateModel

  updateModel: (data) ->
    model = data
    @set model
    @publishEvent 'resumeReady'
