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

  it 'should delegate to addToVirtualCart when call addToCart & not logged in', ->
    cartItems = id: 1, quantity: 1

    Winbits.addToCart(cartItems)

    expect(cartUtils.addToVirtualCart).to.has.been.calledWith(cartItems)
        .and.to.has.been.calledOn(Winbits)
        .and.to.has.been.calledOnce

  it 'should delegate to addToUserCart when call addToCart & logged in', ->
    utils.isLoggedIn.returns(yes)
    cartItems = id: 1, quantity: 1

    Winbits.addToCart(cartItems)

    expect(cartUtils.addToUserCart).to.has.been.calledWith(cartItems)
        .and.to.has.been.calledOn(Winbits)
        .and.to.has.been.calledOnce

