utils = require 'lib/utils'
$ = Winbits.$
rpc = Winbits.env.get('rpc')
env = Winbits.env

describe 'UtilsSpec', ->

  beforeEach ->
    sinon.stub(rpc, 'storeVirtualCart')

  afterEach ->
    rpc.storeVirtualCart.restore()
    env.get.restore?()

  it 'saveVirtualCart should store virtual cart on localStorage', ->
    cartData =
      itemsCount : 2
      cartDetails: [
        quantity: 2
        skuProfile: id: 1
      ]

    utils.saveVirtualCart(cartData)

    expect(localStorage['wb-vcart']).to.be.equal('[{"1":2}]')

  it 'saveVirtualCart should store virtual cart on API domain', ->
    cartData =
      itemsCount : 2
      cartDetails: [
        quantity: 2
        skuProfile: id: 1
      ]

    utils.saveVirtualCart(cartData)

    expect(rpc.storeVirtualCart).to.has.been.calledWith('[{"1":2}]')
        .and.to.has.been.calledOnce

  it 'getResourceURL should build an API resource URL', ->
    sinon.stub(env, 'get')
    env.get.withArgs('api-url').returns('https://apitest.winbits.com/v1')

    expect(utils.getResourceURL('xxx.json')).to.be.equal('https://apitest.winbits.com/v1/xxx.json')

  it 'saveVirtualCartInStorage should store virtual cart on localStorage when don\'t pass params', ->
    utils.saveVirtualCartInStorage()
    expect(localStorage['wb-vcart']).to.be.equal('[]')

  it 'saveVirtualCart should store virtual cart on API domain when don\'t have cart details ', ->
    cartData =
      itemsCount : 2
      cartDetails: []

    utils.saveVirtualCart(cartData)

    expect(rpc.storeVirtualCart).to.has.been.calledWith('[]')
    .and.to.has.been.calledOnce