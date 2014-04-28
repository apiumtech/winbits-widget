Cart = require 'models/cart/cart'
utils = require 'lib/utils'
$ = Winbits.$

describe 'CartSpec', ->

  CART_URL = utils.getResourceURL('orders/cart-items.json')

  before ->
    sinon.stub(utils, 'getApiToken').returns('XXX')
    sinon.stub(utils, 'isLoggedIn').returns(yes)

  after ->
    utils.getApiToken.restore()
    utils.isLoggedIn.restore()

  beforeEach ->
    @xhr = sinon.useFakeXMLHttpRequest()
    requests = @requests = []
    @xhr.onCreate = (xhr) -> requests.push(xhr)
    @model = new Cart

  afterEach ->
    @model.dispose()
    @xhr.restore()

  it 'should use cart items url', ->
    expect(@model.url()).to.be.equal(CART_URL)

  it 'should fetch cart items', ->
    @model.fetch()

    request = @requests[0]
    expect(request.url).to.be.equal(CART_URL)
    expect(request.method).to.be.equal('GET')
    expect(request.async).to.be.true
    expect(request.requestHeaders).to.has.property('Wb-Api-Token', 'XXX')
    expect(request.requestHeaders).to.not.include.keys('Wb-VCart')

  it 'should has accessor for cartTotal', ->
    @model.set(itemsTotal: 100, shippingTotal: 50, bitsTotal: 20)

    cartTotal = @model.cartTotal()

    expect(cartTotal).to.be.equal(30)
