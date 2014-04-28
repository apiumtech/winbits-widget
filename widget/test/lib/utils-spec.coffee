utils = require 'lib/utils'
$ = Winbits.$
rpc = Winbits.env.get('rpc')

describe 'UtilsSpec', ->

  beforeEach ->
    sinon.stub(rpc, 'storeVirtualCart')

  afterEach ->
    rpc.storeVirtualCart.restore()

  it 'saveVirtualCart should store virtual cart on localStorage', ->
    cartData =
      cartDetails: [
        quantity: 2
        skuProfile: id: 1
      ]

    utils.saveVirtualCart(cartData)

    expect(localStorage['wb-vcart']).to.be.equal('[{"1":2}]')

  it 'saveVirtualCart should store virtual cart API domain', ->
    cartData =
      cartDetails: [
        quantity: 2
        skuProfile: id: 1
      ]

    utils.saveVirtualCart(cartData)

    expect(rpc.storeVirtualCart).to.has.been.calledWith('[{"1":2}]')
        .and.to.has.been.calledOnce
