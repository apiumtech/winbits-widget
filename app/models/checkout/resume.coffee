ChaplinModel = require 'chaplin/models/model'
mediator = require 'chaplin/mediator'
util = require 'lib/util'
config = require 'config'
module.exports = class Resume extends ChaplinModel

  initialize: (attributes, option) ->
    super
    @subscribeEvent 'updateResumeModel', @updateModel

  updateModel: (data) ->
    @set data
    @publishEvent 'resumeReady'