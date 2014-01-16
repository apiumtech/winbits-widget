ChaplinModel = require 'chaplin/models/model'
mediator = require 'chaplin/mediator'

module.exports = class FailedCartItems extends ChaplinModel

  initialize: () ->
    super
    @subscribeEvent 'cartUpdated', @updateModel

  updateModel: (data, cartTransferred) ->
    warningCartItems = _.filter data.cartDetails, (cartDetail) ->
      cartDetail.warnings and cartDetail.warnings.length
    if data.failedCartDetails or warningCartItems.length
      @set failedCartItems: data.failedCartDetails, warningCartItems: warningCartItems
      @publishEvent('cartItemsIssues')
    else if cartTransferred
      @publishEvent 'doCheckout' if mediator.flags.autoCheckout
