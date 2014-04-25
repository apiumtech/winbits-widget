CartBitsView = require 'views/cart/cart-bits-view'
Cart = require 'models/cart/cart'
$ = Winbits.$

describe 'CartBitsViewSpec', ->

  beforeEach ->
    @model = new Cart
    @view = new CartBitsView model: @model

  afterEach ->
    @view.dispose()
    @model.dispose()

  it 'should be rendered', ->
    expect(@view.$el).to.has.id('wbi-cart-bits')
        .and.to.has.$class('winSave')
    expect(@view.$ '#wbi-cart-cashback').to.exist
    expect(@view.$ '#wbi-cart-percentage-saved').to.exist
    expect(@view.$ 'input#wbi-cart-bits-slider').to.exist

  it 'should render defaults', ->
    expect(@view.$ '#wbi-cart-cashback').to.has.$text('0')
    expect(@view.$ '#wbi-cart-percentage-saved').to.has.$text('0%')
    expect(@view.$ 'input#wbi-cart-bits-slider').to.has.$val('0')

  it 'should render cart cashback', ->
    @model.set cashback: 100

    @view.render()

    expect(@view.$ '#wbi-cart-cashback').to.has.$text('100')

  it 'should render cart percentage saved', ->
    @model.set(itemsTotal: 100, shippingTotal: 50, bitsTotal: 20)

    @view.render()

    expect(@view.$ '#wbi-cart-percentage-saved').to.has.$text('70%')

  it 'should render cart bits slider', ->
    @model.set(itemsTotal: 100, shippingTotal: 50, bitsTotal: 20)

    @view.render()

    expect(@view.$ 'input#wbi-cart-bits-slider').to.has.$val('20')

