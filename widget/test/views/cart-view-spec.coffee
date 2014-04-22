CartView = require 'views/cart/cart-view'
# Cart = require 'models/cart/cart'
$ = Winbits.$

describe 'CartViewSpec', ->

  beforeEach ->
    # @model = new Cart
    @el = $('<li>', id: 'wbi-cart-holder').get(0)
    @view = new CartView container: @el# model: @model

  afterEach ->
    @view.dispose()
    # @model.dispose()

  it 'should be rendered', ->
    expect(@view.el).to.be.equal(@el)
    expect(@view.noWrap, 'expected to not be wrapped').to.be.true
    expect(@view.$ '#wbi-cart-counter').to.exist
        .and.to.be.displayed
    expect(@view.$ '#wbi-cart-icon').to.exist
        .and.to.be.displayed
    expect(@view.$ '#wbi-cart-drop').to.exist
        .and.to.not.be.displayed
