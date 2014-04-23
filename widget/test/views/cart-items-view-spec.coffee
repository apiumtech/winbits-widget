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

  it 'should render cart items', ->
    $cartItems = @view.$('#wbi-cart-items-list').children()

    expect($cartItems).to.has.property('length', 3)
    $cartItem = $cartItems.get(0)
    expect($cartItem.find('.wbc-item-image')).to.exist
    expect($cartItem.find('.wbc-item-description')).to.exist
    expect($cartItem.find('.wbc-item-attributes')).to.exist
    expect($cartItem.find('.wbc-item-quantity')).to.exist

  it 'should apply scrollpane plugin to items list', ->
    scrollpaneStub = sinon.spy($.fn, 'scrollpane')

    @view.render()

    expect(scrollpaneStub).to.have.been.calledWith(parent: '#wbi-cart-drop')
        .and.to.have.been.calledOnce
    expect(scrollpaneStub.firstCall.returnValue.get(0)).to.be.equal(@view.el)
