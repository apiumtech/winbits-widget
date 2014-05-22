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
    orderId = Winbits.checkoutConfig.orderId
    @order_id = orderId
    util.showAjaxIndicator('Inicializando checkout...')
    that= @
    util.ajaxRequest( config.apiUrl + "/orders/orders/"+ orderId + "/checkoutInfo.json",
      dataType: "json"
      headers:{ 'Accept-Language': 'es', 'WB-Api-Token': util.retrieveKey(config.apiTokenName) }
      success: (data) ->
        that.initCheckout data.response
        util.hideAjaxIndicator()
      error: ->
        util.showAjaxIndicator("La orden NO puede ser procesada." + "<br/> Se redireccionará en 5 segundos")
        setTimeout () ->
          window.location.href = Winbits.checkoutConfig.verticalUrl
        , 5000
    )


  initCheckout: (orderData)->
    that=this
    @addressCK = new AddressCK
    @orderDetails = new OrderDetails
    @payments = new Payments
    @confirm = new Confirm
    @confirmView = new ConfirmView({model: @confirm})
    @addressManagerView = new AddressManagerView({model: @addressCK})
    @paymentView = new PaymentView({model: @payments})
    @orderDetailView = new OrderDetailView({model: @orderDetails})
    @order_data = orderData

    amexSupported = @isPaymentMethodSupported @order_data.paymentMethods, 'amex.'
    cybersourceSupported = @isPaymentMethodSupported @order_data.paymentMethods, 'cybersource.token'
#    if amexSupported or cybersourceSupported
    @cards = new Cards

    @payments.set methods:@order_data.paymentMethods

    # @orderDetailView.render()
    @paymentView.render()

    @orderDetails.on "change", ->
      that.orderDetailView.render()

    @orderDetails.set @orderDetails.completeOrderModel @order_data, parseFloat(Winbits.checkoutConfig.bitsBalance)
    @cards.set(methods: @order_data.paymentMethods)
    @cardsView = new CardsView(model: @cards)
    @cardsView.amexSupported = amexSupported
    @cardsView.cybersourceSupported = cybersourceSupported
    @paymentView.cardsView = @cardsView

    @payments.on "change", ->
      that.paymentView.render()
      that.cardsView.render()

    @cards.on 'change', ->
      that.cardsView.render()

    @addressCK.on "change", ->
      if mediator.post_checkout
        mediator.post_checkout.order = that.order_data.id
      if mediator.profile
        mediator.profile.bitsBalance = that.bits_balance
      that.addressManagerView.render()

    @confirm.on "change", ->
      that.confirmView.render()

    requires = true  for sku in  @order_data.orderDetails when sku.requiresShipping == true
    if requires == true 
      @publishEvent "showStep", ".shippingAddressesContainer"
    else
      @publishEvent "showStep", ".checkoutPaymentContainer"
      @publishEvent "hideAddress"

    @publishEvent 'showCardsManager'

  isPaymentMethodSupported: (paymentMethods, identifier) ->
    $ = Winbits.$
    result = $.grep paymentMethods, (paymentMethod) ->
      paymentMethod.identifier.indexOf(identifier) is 0
    result.length isnt 0
