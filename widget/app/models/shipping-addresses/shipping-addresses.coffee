Model = require 'models/base/model'
utils = require 'lib/utils'
env = Winbits.env
$ = Winbits.$


module.exports = class ShippingAddresses extends Model
  url: env.get('api-url') +  "/users/shipping-addresses.json"
  needsAuth: true

  initialize: ()->
    super
