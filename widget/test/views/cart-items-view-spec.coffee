CartItemsView = require 'views/cart/cart-items-view'
$ = Winbits.$

describe 'CartItemsViewSpec', ->

  beforeEach ->
    @view = new CartItemsView

  afterEach ->
    @view.dispose()

  it 'should be rendered', ->
    expect(@view.$el).to.has.id('wbi-cart-items')
        .and.to.has.classes(['carritoContainer', 'scrollPanel'])
        .and.to.has.attr('data-content', 'carritoContent')
    expect(@view.$ '#wbi-cart-items-list').to.exist
