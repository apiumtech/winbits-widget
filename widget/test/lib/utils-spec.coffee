'use strict'

utils = require 'lib/utils'
$ = Winbits.$
rpc = Winbits.env.get('rpc')
env = Winbits.env
mediator = Winbits.Chaplin.mediator

describe 'UtilsSpec', ->

  DEFAULT_EMPTY_VIRTUAL_CART = '{"cartItems":[], "bits":0}'
  DEFAULT_EMPTY_VIRTUAL_CART_WITHOUT_SPACE = '{"cartItems":[],"bits":0}'
  DEFAULT_VIRTUAL_CART_WHIT_ONCE_VALUE = '{"cartItems":[{"1":2}],"bits":0}'
  DEFAULT_VIRTUAL_CART_ONLY_WITH_BITS = '{"cartItems":[],"bits":8}'


  beforeEach ->
    sinon.stub(rpc, 'storeVirtualCart')

  afterEach ->
    rpc.storeVirtualCart.restore()
    env.get.restore?()

  it 'saveVirtualCart should store virtual cart on mediator', ->
    saveCartData()

    expect(mediator.data.get('virtual-cart')).to.be.equal(DEFAULT_VIRTUAL_CART_WHIT_ONCE_VALUE)

  it 'saveVirtualCart should store virtual cart on API domain', ->
    saveCartData()

    expect(rpc.storeVirtualCart).to.has.been.calledWith(DEFAULT_VIRTUAL_CART_WHIT_ONCE_VALUE)
        .and.to.has.been.calledOnce

  it 'getResourceURL should build an API resource URL', ->
    sinon.stub(env, 'get')
    env.get.withArgs('api-url').returns('https://apitest.winbits.com/v1')

    expect(utils.getResourceURL('xxx.json')).to.be.equal('https://apitest.winbits.com/v1/xxx.json')

  it 'saveVirtualCartInStorage should store virtual cart on mediator when don\'t pass params', ->
    utils.saveVirtualCartInStorage()
    expect(mediator.data.get('virtual-cart')).to.be.equal(DEFAULT_EMPTY_VIRTUAL_CART)

  it 'saveVirtualCart should store virtual cart on API domain when don\'t have cart details ', ->
    cartData =
      itemsCount : 2
      cartDetails: []

    utils.saveVirtualCart(cartData)

    expect(rpc.storeVirtualCart).to.has.been.calledWith(DEFAULT_EMPTY_VIRTUAL_CART_WITHOUT_SPACE)
    .and.to.has.been.calledOnce

  it "get virtual cart when don't have values", ->
    expect(utils.getVirtualCart()).to.be.equal DEFAULT_EMPTY_VIRTUAL_CART_WITHOUT_SPACE

  it "get cart items from virtual cart when don't have values", ->
    expect(utils.getCartItemsToVirtualCart()).to.be.equal '[]'

  it "get bits from virtual cart when don't have values", ->
    expect(utils.getBitsToVirtualCart()).to.be.equal 0

  it 'get cart items from virtual cart', ->
    saveCartData()
    expect(utils.getCartItemsToVirtualCart()).to.be.equal '[{"1":2}]'

  it "save bits in virtual cart", ->
    mediator.data.set 'virtual-cart', DEFAULT_EMPTY_VIRTUAL_CART
    utils.saveBitsInVirtualCart(8)
    expect(mediator.data.get('virtual-cart')).to.be.equal(DEFAULT_VIRTUAL_CART_ONLY_WITH_BITS)

  it "get bits from virtual cart", ->
    utils.saveBitsInVirtualCart(8)
    expect(utils.getBitsToVirtualCart()).to.be.equal 8

  saveCartData = ->
    cartData =
      itemsCount : 2
      cartDetails: [
        quantity: 2
        skuProfile: id: 1
      ]
    utils.saveVirtualCart(cartData)
