ChaplinController = require 'chaplin/controller/controller'
CheckoutSiteView = require 'views/checkout/checkout-site-view'
AddressManagerView = require "views/checkout/address-manager-view"
PaymentView = require "views/checkout/payment-view"
AddressCK = require "models/checkout/addressCK"
OrderDetails = require "models/checkout/orderDetails"
OrderDetailView = require "views/checkout/orderDetail-view"
Payments = require "models/checkout/payments"
mediator = require 'chaplin/mediator'
config = require 'config'
util = require 'lib/util'

module.exports = class CheckoutController extends ChaplinController

  initialize: ->
    super
    @checkoutSiteView = new CheckoutSiteView()

  index: ->
    console.log ":-02"
    that=this
    @addressCK = new AddressCK
    @orderDetails = new OrderDetails
    @payments = new Payments
    @addressManagerView = new AddressManagerView({model: @addressCK})
    @paymentView = new PaymentView({model: @payments})
    @orderDetailView = new OrderDetailView({model: @orderDetails})
    @order_data = JSON.parse(window.order_data)
    console.log @order_data

    console.log ['Bits Balance', window.bits_balance]
    @orderDetails.set @orderDetails.completeOrderModel @order_data, parseInt(window.bits_balance)


    @payments.set @order_data.paymentMethods

    @orderDetailView.render()
    @paymentView.render()

    @addressCK.on "change", ->
      console.log "address change"
      if mediator.post_checkout
        mediator.post_checkout.order = that.order_data.id
      if mediator.profile
        mediator.profile.bitsBalance = that.bits_balance
      that.addressManagerView.render()

    @orderDetails.on "change", ->
      console.log "ordersDetail  change"
    @payments.on "change", ->
      console.log "---->"

    if @order_data.shippingTotal > 0
      @publishEvent "showStep", ".shippingAddressesContainer"


