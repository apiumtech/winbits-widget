cartUtils = require 'lib/cart-utils'
utils = require 'lib/utils'
$ = Winbits.$

describe 'CartUtilsSpec', ->

  VIRTUAL_CART_URL = utils.getResourceURL('orders/virtual-cart-items.json')
  CART_URL = utils.getResourceURL('orders/cart-items.json')
  ADD_TO_CART_SUCCESS_RESPONSE = '{"meta":{"status":200},"response":{"itemsTotal":10,"itemsCount":1,"shippingTotal":250,"cartDetails":[{"quantity":1,"skuProfile":{"id":1,"price":10,"fullPrice":100,"item":{"attributeLabel":"attributeLabel","name":"ItemGroupProfile","vertical":{"name":"_Test_","logo":"http://www.winbits-test.com"},"thumbnail":null},"attributes":[],"mainAttribute":{"name":"attributeName","label":"attributeLabel","type":"TEXT","value":"attributeValue"},"vertical":{"name":"_Test_","logo":"http://www.winbits-test.com"}},"min":1,"max":100,"warnings":null}],"cashback":0}}'

  before ->
    sinon.stub(utils, 'getApiToken').returns(undefined)
    sinon.stub(utils, 'isLoggedIn').returns(no)

  after ->
    utils.getApiToken.restore()
    utils.isLoggedIn.restore()

  beforeEach ->
    @xhr = sinon.useFakeXMLHttpRequest()
    requests = @requests = []
    @xhr.onCreate = (xhr) -> requests.push(xhr)
    sinon.spy(utils, 'ajaxRequest')

  afterEach ->
    @xhr.restore()
    utils.ajaxRequest.restore()
    utils.saveVirtualCart.restore?()

  it 'should request to add items to virtual cart', ->
    promise = cartUtils.addToVirtualCart([{ id: 1, quantity: 2 }, { id: 2, quantity: 3 }])
    expect(promise).to.be.promise

    request = @requests[0]
    expect(request.url).to.be.equal(VIRTUAL_CART_URL)
    expect(request.method).to.be.equal('POST')
    expect(request.async).to.be.true
    expect(request.requestHeaders).to.has.property('Wb-VCart', '[]')
    expect(request.requestHeaders).to.has.property('Content-Type', 'application/json;charset=utf-8')
    expect(request.requestBody).to.be.equal('{"cartItems":[{"skuProfileId":1,"quantity":2},{"skuProfileId":2,"quantity":3}]}')

  it 'should save virtual cart when items successfully added', ->
    sinon.stub(utils, 'saveVirtualCart')
    cartUtils.addToVirtualCart([id: 1, quantity: 2])

    request = @requests[0]
    request.respond(201, { "Content-Type": "application/json" }, ADD_TO_CART_SUCCESS_RESPONSE);

    expect(utils.saveVirtualCart).to.have.been.calledWith(JSON.parse(ADD_TO_CART_SUCCESS_RESPONSE).response)
        .and.to.be.calledOnce

  it 'should request to add items to user cart', ->
    utils.getApiToken.returns('XXX')
    utils.isLoggedIn.returns(yes)
    promise = cartUtils.addToUserCart([{ id: 1, quantity: 2 }, { id: 2, quantity: 3 }])
    expect(promise).to.be.promise

    request = @requests[0]
    expect(request.url).to.be.equal(CART_URL)
    expect(request.method).to.be.equal('POST')
    expect(request.async).to.be.true
    expect(request.requestHeaders).to.has.property('Wb-Api-Token', 'XXX')
    expect(request.requestHeaders).to.has.property('Content-Type', 'application/json;charset=utf-8')
    expect(request.requestBody).to.be.equal('{"cartItems":[{"skuProfileId":1,"quantity":2},{"skuProfileId":2,"quantity":3}]}')
