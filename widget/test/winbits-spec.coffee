cartUtils = require 'lib/cart-utils'
utils = require 'lib/utils'
$ = Winbits.$

describe 'WinbitsSpec', ->

  beforeEach ->
    sinon.stub(utils, 'isLoggedIn').returns(no)
    sinon.stub(cartUtils, 'addToVirtualCart')
    sinon.stub(cartUtils, 'addToUserCart')

  afterEach ->
    utils.isLoggedIn.restore()
    cartUtils.addToVirtualCart.restore()
    cartUtils.addToUserCart.restore()

  it 'addToCart should transform parameter to Array', ->
    cartItem = id: 1, quantity: 1
    Winbits.addToCart(cartItem)

    expect(cartUtils.addToVirtualCart).to.has.been.calledWith([cartItem])
        .and.to.has.been.calledOn(cartUtils)

  it 'addToCart should delegate to addToVirtualCart when not logged in', ->
    Winbits.addToCart([id: 1, quantity: 1])

    expect(cartUtils.addToVirtualCart).and.to.has.been.calledOnce

  it 'addToCart should delegate to addToUserCart when logged in', ->
    utils.isLoggedIn.returns(yes)
    cartItems = [id: 1, quantity: 1]

    Winbits.addToCart(cartItems)

    expect(cartUtils.addToUserCart).to.has.been.calledWith(cartItems)
        .and.to.has.been.calledOn(cartUtils)
        .and.to.has.been.calledOnce

