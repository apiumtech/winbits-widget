ChaplinController = require 'chaplin/controller/controller'
CheckoutSiteView = require 'views/checkout/checkout-site-view'
AddressManagerView = require "views/checkout/address-manager-view"
PaymentView = require "views/checkout/payment-view"

module.exports = class CheckoutController extends ChaplinController

  initialize: ->
    super
    @checkoutSiteView = new CheckoutSiteView()

  index: ->
    console.log ":-01"
    @checkoutSiteView.render()
    @addressManagerView = new AddressManagerView()
    @paymentView = new PaymentView()

    @publishEvent "showStep", ".shippingAddressesContainer"
