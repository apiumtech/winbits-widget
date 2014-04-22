CartTotalsView = require 'views/cart/cart-totals-view'
Cart = require 'models/cart/cart'
$ = Winbits.$

describe 'CartTotalsViewSpec', ->

  beforeEach ->
    @model = new Cart
    @view = new CartTotalsView model: @model

  afterEach ->
    @view.dispose()
    @model.dispose()

  it 'should be rendered', ->
    expect(@view.$el).to.has.id('wbi-cart-totals')
    expect(@view.$ '#wbi-cart-subtotal').to.exist
    expect(@view.$ '#wbi-cart-saving').to.exist
    expect(@view.$ '#wbi-cart-shipping-cost').to.exist
    expect(@view.$ '#wbi-cart-total').to.exist

  it 'should render default cart totals', ->
    zeroPesos = '$0'
    expect(@view.$('#wbi-cart-subtotal'), 'invalid cart subtotal').to.has.text(zeroPesos)
    expect(@view.$('#wbi-cart-saving'), 'invalid cart saving').to.has.text(zeroPesos)
    expect(@view.$('#wbi-cart-shipping-cost'), 'invalid cart shipping cost').to.has.text(zeroPesos)
    expect(@view.$('#wbi-cart-total'), 'invalid cart total').to.has.text(zeroPesos)
