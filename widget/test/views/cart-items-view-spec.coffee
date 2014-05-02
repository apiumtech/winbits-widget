'use strict'
CartItemsView = require 'views/cart/cart-items-view'
Cart = require 'models/cart/cart'
$ = Winbits.$
utils = require 'lib/utils'

describe 'CartItemsViewSpec', ->

  beforeEach ->
    @model = new Cart cartDetails: [
      generateCartDetail(1)
      generateCartDetail(2)
      generateCartDetail(3)
    ]
    sinon.stub(@model, 'fetch')
    @view = new CartItemsView model: @model

  afterEach ->
    @model.fetch.restore()
    @model.dispose()
    @view.dispose()
    utils.showMessageModal.restore?()

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

  it     'should render cart item', ->
    $cartItem = @view.$('#wbi-cart-items-list').children().eq(0)
    expect($cartItem).to.has.data('id', 1)
    expect($cartItem.find('.wbc-item-image')).to.exist
    expect($cartItem.find('.wbc-item-description')).to.exist
    expect($cartItem.find('.wbc-item-attributes')).to.exist
    expect($cartItem.find('.wbc-item-quantity')).to.exist
    expect($cartItem.find('.wbc-item-price')).to.exist
    expect($cartItem.find('.wbc-item-vertical-logo')).to.exist
    expect($cartItem.find('.wbc-item-delete-link')).to.exist

  it  'should render item image', ->
    $cartItem = @view.$('#wbi-cart-items-list').children().eq(0)

    $itemImage = $cartItem.find('.wbc-item-image')
    expect($itemImage).to.existExact(1)
    expect($itemImage).to.has.attr('src', '//cdn.winbits.com/item-1.jpg')
    expect($itemImage).to.has.attr('alt', 'Item 1')

  it  'should render item description', ->
    $cartItem = @view.$('#wbi-cart-items-list').children().eq(0)

    $itemImage = $cartItem.find('.wbc-item-description')
    expect($itemImage).to.existExact(1)
    expect($itemImage).to.has.text('Item 1')

  it  'should render item attributes', ->
    $cartItem = @view.$('#wbi-cart-items-list').children().eq(0)

    $itemImage = $cartItem.find('.wbc-item-attributes')
    expect($itemImage).to.existExact(1)
    expect($itemImage.text()).to.be.equal('Color: Negro, Talla: M')

  it  'should render item quantity', ->
    $cartItem = @view.$('#wbi-cart-items-list').children().eq(0)

    $itemQuantity = $cartItem.find('.wbc-item-quantity')
    expect($itemQuantity).to.existExact(1)
    expect($itemQuantity.val()).to.be.equal('2')

  it  'should render item quantities', ->
    $cartItem = @view.$('#wbi-cart-items-list').children().eq(0)

    $itemQuantities = $cartItem.find('.wbc-item-quantity').children()
    expect($itemQuantities).to.existExact(5)
    expect($itemQuantities.first()).to.has.text('1')
        .and.to.has.attr('value', '1')
    expect($itemQuantities).to.existExact(5)
    expect($itemQuantities.last()).to.has.text('5')
        .and.to.has.attr('value', '5')

  it  'should render just one selected quantity option', ->
    $cartItem = @view.$('#wbi-cart-items-list').children().eq(0)

    $selectedAttr = $cartItem.find('.wbc-item-quantity').children('[selected]')
    expect($selectedAttr).to.has.existExact(1)
    expect($selectedAttr).to.has.text('2')
        .and.to.has.attr('value', '2')

  it  'should apply customSelect plugin to each cart item quantity select', ->
    customSelectSpy = sinon.spy($.fn, 'customSelect')

    @view.render()

    expect(customSelectSpy).to.have.been.calledOnce
    expect(customSelectSpy.firstCall.returnValue).to.has.property('length', 3)

  it  'should render item price', ->
    $cartItem = @view.$('#wbi-cart-items-list').children().eq(0)

    expect($cartItem.find '.wbc-item-price').to.has.$text('$200')

  it  'should render cart item vertical info', ->
    $cartItem = @view.$('#wbi-cart-items-list').children().eq(0)

    expect($cartItem.find '.wbc-item-vertical-logo').to.has.$class('vertical1')
        .and.to.has.$attr('title', 'Vertical 1')

  it  'do request should update success cart item', ->
    sinon.stub(utils, 'showMessageModal')
    sinon.stub(@model, 'requestToUpdateCart').returns TestUtils.promises.resolved
    $UIRS = sinon.stub @view, 'doUpdateItemRequestSuccess'
    $UIRE = sinon.stub @view, 'doUpdateItemRequestError'
    $item1= @view.$('#wbi-cart-items-list').children('li')[0]
    $selectQuantity= $($item1).find('.wbc-item-quantity')
    $selectQuantity.val 4
    $selectQuantity.change()
    expect($UIRS).to.be.calledOnce
    expect($UIRE).to.not.be.calledOnce


  it  'do request should update error cart item', ->
    sinon.stub(utils, 'showMessageModal')
    sinon.stub(@model, 'requestToUpdateCart').returns TestUtils.promises.rejected
    $UIRS = sinon.stub @view, 'doUpdateItemRequestSuccess'
    $UIRE = sinon.stub @view, 'doUpdateItemRequestError'
    $item1= @view.$('#wbi-cart-items-list').children('li')[0]
    $selectQuantity= $($item1).find('.wbc-item-quantity')
    $selectQuantity.val 4
    $selectQuantity.change()
    expect($UIRE).to.be.calledOnce
    expect($UIRS).to.not.be.calledOnce

  generateCartDetail = (id) ->
    vertical = id: 1, name: "Vertical #{id}", logo: "//cdn.winbits.com/vertical-#{id}.jpg"
    colorLabel = ['Blanco', 'Negro', 'Rojo'][id] or 'Verde'
    colorValue = ['#fff', '#000', '#f00'][id] or '#0f0'
    size = ['C', 'M', 'G'][id] or 'XG'

    quantity: id + 1
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
