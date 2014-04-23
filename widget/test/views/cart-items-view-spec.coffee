CartItemsView = require 'views/cart/cart-items-view'
Cart = require 'models/cart/cart'
$ = Winbits.$

describe 'CartItemsViewSpec', ->

  beforeEach ->
    @model = new Cart cartDetails: [
      generateCartDetail(1)
      generateCartDetail(2)
      generateCartDetail(3)
    ]
    @view = new CartItemsView model: @model

  afterEach ->
    @view.dispose()
    @model.dispose()

  it 'should be rendered', ->
    expect(@view.$el).to.has.id('wbi-cart-items')
        .and.to.has.classes(['carritoContainer', 'scrollPanel'])
        .and.to.has.attr('data-content', 'carritoContent')
    expect(@view.$ '#wbi-cart-items-list').to.exist

  it 'should apply scrollpane plugin to items list', ->
    scrollpaneStub = sinon.spy($.fn, 'scrollpane')

    @view.render()

    expect(scrollpaneStub).to.have.been.calledWith(parent: '#wbi-cart-drop')
        .and.to.have.been.calledOnce
    expect(scrollpaneStub.firstCall.returnValue.get(0)).to.be.equal(@view.el)

  it 'should render cart items', ->
    $cartItems = @view.$('#wbi-cart-items-list').children()
    expect($cartItems).to.has.property('length', 3)

    $cartItem = $cartItems.eq(0)
    expect($cartItem.find('.wbc-item-image')).to.exist
    expect($cartItem.find('.wbc-item-description')).to.exist
    expect($cartItem.find('.wbc-item-attributes')).to.exist
    expect($cartItem.find('.wbc-item-quantity')).to.exist
    expect($cartItem.find('.wbc-item-price')).to.exist
    expect($cartItem.find('.wbc-item-vertical-logo')).to.exist
    expect($cartItem.find('.wbc-item-delete-link')).to.exist

  it 'should render item image', ->
    $cartItem = @view.$('#wbi-cart-items-list').children().eq(0)

    $itemImage = $cartItem.find('.wbc-item-image')
    expect($itemImage).to.existExact(1)
    expect($itemImage).to.has.attr('src', '//cdn.winbits.com/item-1.jpg')
    expect($itemImage).to.has.attr('alt', 'Item 1')

  it 'should render item description', ->
    $cartItem = @view.$('#wbi-cart-items-list').children().eq(0)

    $itemImage = $cartItem.find('.wbc-item-description')
    expect($itemImage).to.existExact(1)
    expect($itemImage).to.has.text('Item 1')

  generateCartDetail = (id) ->
    vertical = name: "Vertical #{id}", logo: "//cdn.winbits.com/vertical-#{id}.jpg"
    colorLabel = ['Blanco', 'Negro', 'Rojo'][id] or 'Verde'
    colorValue = ['#fff', '#000', '#f00'][id] or '#0f0'
    size = ['C', 'M', 'G'][id] or 'XG'
    quantity: id
    skuProfile:
      id: id
      price: id * 10
      fullPrice: id * 100
      item:
        attributeLabel: 'Color'
        name: "Item #{id}"
        vertical: vertical
        thumbnail: "//cdn.winbits.com/item-#{id}.jpg"
      attributes: [
        name: 'Talla'
        label: size
        value: size
        type: 'TEXT'
      ]
      mainAttribute:
        name: 'Color'
        label: colorLabel
        type: 'COLOR',
        value: colorValue
      vertical: vertical
    min: 1
    max: 5
