Cart = require 'models/cart/cart'
utils = require 'lib/utils'
$ = Winbits.$

describe 'VirtualCartSpec', ->

  VIRTUAL_CART_URL = utils.getResourceURL('orders/virtual-cart-items.json')

  before ->
    sinon.stub(utils, 'getApiToken').returns(undefined)
    sinon.stub(utils, 'isLoggedIn').returns(no)

  after ->
    utils.getApiToken.restore()
    utils.isLoggedIn.restore()

  beforeEach ->
    localStorage.removeItem('wb-vcart')
    @xhr = sinon.useFakeXMLHttpRequest()
    requests = @requests = []
    @xhr.onCreate = (xhr) -> requests.push(xhr)
    @model = new Cart needsAuth: no
    sinon.spy(utils, 'ajaxRequest')

  afterEach ->
    @model.dispose()
    @xhr.restore()
    utils.ajaxRequest.restore()
    utils.saveVirtualCart.restore?()

  it 'should use virtual cart items url', ->
    expect(@model.url()).to.be.equal(VIRTUAL_CART_URL)

  it 'should fetch virtual cart items', ->
    @model.fetch()
    request = @requests[0]
    expect(request.url).to.be.equal(VIRTUAL_CART_URL)
    expect(request.method).to.be.equal('GET')
    expect(request.async).to.be.true
    expect(request.requestHeaders).to.has.property('Wb-VCart', '[]')
    expect(request.requestHeaders).to.not.include.keys('Wb-Api-Token')
