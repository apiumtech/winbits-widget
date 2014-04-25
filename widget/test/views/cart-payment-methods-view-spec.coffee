CartPaymentMethodsView = require 'views/cart/cart-payment-methods-view'
$ = Winbits.$

describe 'CartPaymentMethodsViewSpec', ->

  beforeEach ->
    @view = new CartPaymentMethodsView

  afterEach ->
    @view.dispose()

  it 'should be rendered', ->
    expect(@view.$el).to.has.id('wbi-cart-payment-methods')
    expect(@view.$ '#wbi-cart-checkout-btn').to.exist
    expect(@view.$ '#wbi-continue-shopping-link').to.exist
