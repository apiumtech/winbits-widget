require = Winbits.require
Model = require 'models/base/model'
$ = Winbits.$

module.exports = class Cart extends Model
  defaults:
    itemsTotal: 0,
  #   itemsCount: 0,
    bitsTotal: 0,
    shippingTotal: 0,
  #   cartDetails: [],
  #   paymentMethods: [],
    cashback: 0
