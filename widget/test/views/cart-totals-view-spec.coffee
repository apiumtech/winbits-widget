CartTotalsView = require 'views/cart/cart-totals-view'
Cart = require 'models/cart/cart'
$ = Winbits.$

describe 'CartTotalsViewSpec', ->

  beforeEach ->
    @model = new Cart
#    sinon.stub(@model, 'fetch')
    @view = new CartTotalsView model: @model

  afterEach ->
    @view.dispose()
#    @model.fetch.restore()
    @model.dispose()

  it 'should be rendered', ->
    expect(@view.$el).to.has.id('wbi-cart-totals')
    expect(@view.$ '#wbi-cart-subtotal').to.exist
    expect(@view.$ '#wbi-cart-saving').to.exist
    expect(@view.$ '#wbi-cart-shipping-cost').to.exist
    expect(@view.$ '#wbi-cart-total').to.exist

  it.skip 'should render default cart totals', ->
    zeroPesos = '$0'
    expect(@view.$('#wbi-cart-subtotal')).to.has.text(zeroPesos)
#    expect(@view.$('#wbi-cart-saving')).to.has.text(zeroPesos)
#    expect(@view.$('#wbi-cart-shipping-cost')).to.has.text(zeroPesos)
#    expect(@view.$('#wbi-cart-total')).to.has.text(zeroPesos)

  it.skip 'should render cart saving', ->
    expect(no).to.be.ok

  it 'should render cart total', ->
    @model.set(itemsTotal: 100, shippingTotal: 50, bitsTotal: 20)

    @view.render()

    expect(@view.$('#wbi-cart-total')).to.has.$text('$130')
