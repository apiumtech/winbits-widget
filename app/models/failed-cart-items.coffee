ChaplinModel = require 'chaplin/models/model'

module.exports = class FailedCartItems extends ChaplinModel

  initialize: () ->
    super
    @subscribeEvent 'cartUpdated', @updateModel

  updateModel: (data) ->
    warningCartItems = _.filter data.cartDetails, (cartDetail) ->
      cartDetail.warnings and cartDetail.warnings.length
    if data.failedCartDetails or warningCartItems.length
      @set failedCartItems: data.failedCartDetails, warningCartItems: warningCartItems
      @publishEvent('cartItemsIssues')
