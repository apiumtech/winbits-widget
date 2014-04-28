Cart = require 'models/cart/cart'
utils = require 'lib/utils'
$ = Winbits.$

describe 'CartSpec', ->

  before ->
    sinon.stub(utils, 'getApiToken').returns('XXX')

  after ->
    utils.getApiToken.restore()

  beforeEach ->
    @xhr = sinon.useFakeXMLHttpRequest()
    requests = @.requests = []
    @xhr.onCreate = (xhr) -> requests.push(xhr)
    @model = new Cart

  afterEach ->
    @model.dispose()
    @xhr.restore()

  it 'should be fetched', ->
    @model.fetch()

    @request = @requests[0]
    expect(@request.url).to.be.equal('https://apidev.winbits.com/v1/orders/virtual-cart-items.json')
    expect(@request.requestHeaders).to.include.keys('Wb-Api-Token')

  it 'should use virtual cart details url if not logged in', ->
    sinon.stub(utils, 'isLoggedIn').returns(no)

    expect(@model.url()).to.be.equal('https://apidev.winbits.com/v1/orders/virtual-cart-items.json')

    utils.isLoggedIn.restore()

  it 'should use cart details url if logged in', ->
    sinon.stub(utils, 'isLoggedIn').returns(yes)

    expect(@model.url()).to.be.equal('https://apidev.winbits.com/v1/orders/cart-items.json')

    utils.isLoggedIn.restore()
