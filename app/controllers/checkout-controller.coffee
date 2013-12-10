ChaplinController = require 'chaplin/controller/controller'
CheckoutSiteView = require 'views/checkout/checkout-site-view'
AddressManagerView = require "views/checkout/address-manager-view"
PaymentView = require "views/checkout/payment-view"
AddressCK = require "models/checkout/addressCK"
OrderDetails = require "models/checkout/orderDetails"
OrderDetailView = require "views/checkout/orderDetail-view"
Payments = require "models/checkout/payments"
Confirm = require "models/checkout/confirm"
ConfirmView = require "views/checkout/confirm-view"
Cards = require "models/checkout/cards"
CardsView = require "views/checkout/cards-view"
mediator = require 'chaplin/mediator'
config = require 'config'
util = require 'lib/util'

module.exports = class CheckoutController extends ChaplinController

  initialize: ->
    super
    @checkoutSiteView = new CheckoutSiteView()

  index: ->
    that=this
    @addressCK = new AddressCK
    @orderDetails = new OrderDetails
    @payments = new Payments
    @confirm = new Confirm
    @confirmView = new ConfirmView({model: @confirm})
    @addressManagerView = new AddressManagerView({model: @addressCK})
    @paymentView = new PaymentView({model: @payments})
    @orderDetailView = new OrderDetailView({model: @orderDetails})
    @order_data = JSON.parse(window.order_data)

    amexSupported = @isPaymentMethodSupported @order_data.paymentMethods, 'amex.'
    cybersourceSupported = @isPaymentMethodSupported @order_data.paymentMethods, 'cybersource.token'
#    if amexSupported or cybersourceSupported
    @cards = new Cards

    @payments.set methods:@order_data.paymentMethods

    # @orderDetailView.render()
    @paymentView.render()
    @payments.on "change", ->
      console.log "on change payment"
      that.paymentView.render()
    console.log @order_data
    @orderDetails.on "change", ->
      console.log "here order details changeed"
      that.orderDetailView.render()
    @orderDetails.set @orderDetails.completeOrderModel @order_data, parseFloat(window.bits_balance)
    @cards.set(methods: @order_data.paymentMethods)
    @cardsView = new CardsView(model: @cards)
    @cardsView.amexSupported = amexSupported
    @cardsView.cybersourceSupported = cybersourceSupported
    @paymentView.cardsView = @cardsView

    @cards.on 'change', ->
      console.log "Cards model changed"
      that.cardsView.render()

    @addressCK.on "change", ->
      if mediator.post_checkout
        mediator.post_checkout.order = that.order_data.id
      if mediator.profile
        mediator.profile.bitsBalance = that.bits_balance
      that.addressManagerView.render()

    @confirm.on "change", ->
      that.confirmView.render()
    if @order_data.shippingTotal > 0
      @publishEvent "showStep", ".shippingAddressesContainer"
    else
      @publishEvent "showStep", ".checkoutPaymentContainer"
      @publishEvent "hideAddress"

    @publishEvent 'showCardsManager'

  isPaymentMethodSupported: (paymentMethods, identifier) ->
    $ = Backbone.$
    result = $.grep paymentMethods, (paymentMethod) ->
      paymentMethod.identifier.indexOf(identifier) is 0
    result.length isnt 0
