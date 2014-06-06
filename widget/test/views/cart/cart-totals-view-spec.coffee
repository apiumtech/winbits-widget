'use strict'

CartTotalsView = require 'views/cart/cart-totals-view'
Cart = require 'models/cart/cart'
testUtils = require 'test/lib/test-utils'
$ = Winbits.$

describe 'CartTotalsViewSpec', ->

  beforeEach ->
    @model = new Cart
    @view = new CartTotalsView model: @model
    @view.render()

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
    expect(@view.$('#wbi-cart-subtotal')).to.has.text(zeroPesos)
    expect(@view.$('#wbi-cart-items-total')).to.has.text(zeroPesos)
    expect(@view.$('#wbi-cart-saving')).to.has.text(zeroPesos)
    expect(@view.$('#wbi-cart-shipping-cost')).to.has.text(zeroPesos)
    expect(@view.$('#wbi-cart-total')).to.has.text(zeroPesos)

  it 'should render cart saving', ->
    testUtils.setExampleCartDataInto(@model)

    @view.render()
    expect(@view.$('#wbi-cart-saving')).to.has.$text('$821')

  it 'should render cart saving', ->
    testUtils.setExampleCartDataInto(@model)

    @view.render()
    expect(@view.$('#wbi-cart-saving')).to.has.$text('$821')

  it 'should render cart total', ->
    testUtils.setExampleCartDataInto(@model)

    @view.render()
    expect(@view.$('#wbi-cart-total')).to.has.$text('$1079')
