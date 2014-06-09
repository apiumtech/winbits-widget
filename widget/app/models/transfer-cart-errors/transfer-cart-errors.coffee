utils = require 'lib/utils'
Model = require "models/base/model"
env = Winbits.env
$ = Winbits.$

module.exports = class TransferCartErrors extends Model

  initialize: (response)->
    super
    if (response)
      @parse(response)

  parse:(response) ->
    cartDetails = []
    cartDetails.push( cartDetail) for cartDetail in response.cartDetails when not $.isEmptyObject(cartDetail.warnings)
    if (cartDetails)
      @set 'cartDetails', cartDetails
    if (response.failedCartDetails)
      @set 'failedCartDetails', response.failedCartDetails
