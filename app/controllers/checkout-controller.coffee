ChaplinController = require 'chaplin/controller/controller'
CheckoutSiteView = require 'views/checkout/checkout-site-view'
AddressManagerView = require "views/checkout/address-manager-view"
PaymentView = require "views/checkout/payment-view"
AddressCK = require "models/checkout/addressCK"

module.exports = class CheckoutController extends ChaplinController

  initialize: ->
    super
    @checkoutSiteView = new CheckoutSiteView()

  index: ->
    console.log ":-01"
    @checkoutSiteView.render()
    @addressCK = new AddressCK
    @addressManagerView = new AddressManagerView({model: @addressCK})
    @paymentView = new PaymentView()

    @publishEvent "showStep", ".shippingAddressesContainer"
