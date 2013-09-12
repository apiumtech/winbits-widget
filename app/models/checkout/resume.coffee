ChaplinModel = require 'chaplin/models/model'
mediator = require 'chaplin/mediator'
util = require 'lib/util'
config = require 'config'
module.exports = class Resume extends ChaplinModel

  initialize: (attributes, option) ->
    super
    @subscribeEvent 'updateResumeModel', @updateModel

  updateModel: (data) ->
    orderFullPrice = util.calculateOrderFullPrice(data.orderDetails)
    data.orderFullPrice = orderFullPrice
    data.orderSaving = orderFullPrice - data.itemsTotal
    data.maxBits = 600 #Math.min(data.total, mediator.profile.bitsTotal)
    @set data
    @publishEvent 'resumeReady'