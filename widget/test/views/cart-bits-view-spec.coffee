CartBitsView = require 'views/cart/cart-bits-view'
$ = Winbits.$

describe 'CartBitsViewSpec', ->

  beforeEach ->
    @view = new CartBitsView

  afterEach ->
    @view.dispose()

  it 'should be rendered', ->
    expect(@view.$el).to.has.$id('wbi-cart-bits')
        .and.to.has.$class('winSave')
    expect(@view.$ '#wbi-cart-cashback').to.exist
    expect(@view.$ '#wbi-cart-percentage-saved').to.exist
    expect(@view.$ 'input#wbi-cart-bits-slider').to.exist
