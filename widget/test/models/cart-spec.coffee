Cart = require 'models/cart/cart'
utils = require 'lib/utils'
$ = Winbits.$

describe 'CartSpec', ->

  CART_URL = 'https://apidev.winbits.com/v1/orders/cart-items.json'

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
    expect(request.requestHeaders).to.has.property('Wb-Api-Token', 'XXX')
    expect(request.requestHeaders).to.not.include.keys('Wb-VCart')

  it 'should add single item to user cart', ->
    promise = @model.addToUserCart(id: 1, quantity: 2)
    expect(promise).to.be.promise

    request = @requests[0]
    expect(request.url).to.be.equal(CART_URL)
    expect(request.method).to.be.equal('POST')
    expect(request.async).to.be.true
    expect(request.requestHeaders).to.has.property('Wb-Api-Token', 'XXX')
    expect(request.requestBody).to.be.equal('[{"id":1,"quantity":2}]')

  it 'should add several items to user cart', ->
    promise = @model.addToUserCart([{ id: 1, quantity: 2 }, { id: 2, quantity: 3 }])
    expect(promise).to.be.promise

    request = @requests[0]
    expect(request.url).to.be.equal(CART_URL)
    expect(request.method).to.be.equal('POST')
    expect(request.async).to.be.true
    expect(request.requestHeaders).to.has.property('Wb-Api-Token', 'XXX')
    expect(request.requestBody).to.be.equal('[{"id":1,"quantity":2},{"id":2,"quantity":3}]')
