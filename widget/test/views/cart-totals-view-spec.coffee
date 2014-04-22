CartTotalsView = require 'views/cart/cart-totals-view'
$ = Winbits.$

describe 'CartTotalsViewSpec', ->

  beforeEach ->
    @view = new CartTotalsView

  afterEach ->
    @view.dispose()

  it 'should be rendered', ->
    expect(@view.$el).to.has.id('wbi-cart-totals')
    expect(@view.$ '#wbi-cart-subtotal').to.exist
    expect(@view.$ '#wbi-cart-saving').to.exist
    expect(@view.$ '#wbi-cart-shipping-cost').to.exist
    expect(@view.$ '#wbi-cart-total').to.exist
