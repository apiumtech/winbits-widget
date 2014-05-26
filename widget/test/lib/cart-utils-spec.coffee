cartUtils = require 'lib/cart-utils'
utils = require 'lib/utils'
EventBroker = Chaplin.EventBroker
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
    localStorage.removeItem('wb-vcart')
    @xhr = sinon.useFakeXMLHttpRequest()
    requests = @requests = []
    @xhr.onCreate = (xhr) -> requests.push(xhr)
    sinon.spy(utils, 'ajaxRequest')
    sinon.stub(utils, 'saveVirtualCart')

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
#    expect(request.requestHeaders).to.has.property('Wb-VCart', '[]')
    expect(request.requestHeaders).to.has.property('Content-Type', 'application/json;charset=utf-8')
    expect(request.requestBody).to.be.equal('{"cartItems":[{"skuProfileId":1,"quantity":2},{"skuProfileId":2,"quantity":3}]}')

  it 'should save virtual cart when items successfully added', ->
    cartUtils.addToVirtualCart([id: 1, quantity: 2])

    respondSuccess.call(@)

    expect(utils.saveVirtualCart).to.have.been.calledWith(JSON.parse(ADD_TO_CART_SUCCESS_RESPONSE).response)
        .and.to.be.calledOnce

  it 'should trigger "cart-changed" event when items successfully added to virtual cart', ->
    stub = sinon.stub()
    EventBroker.subscribeEvent('cart-changed', stub)

    cartUtils.addToVirtualCart([id: 1, quantity: 2])

    respondSuccess.call(@)

    expect(stub).to.have.been.calledWith(JSON.parse(ADD_TO_CART_SUCCESS_RESPONSE))
        .and.to.be.calledOnce

    EventBroker.unsubscribeEvent('cart-changed', stub)

  it 'should request to add items to user cart', ->
    setLoginContext()
    promise = cartUtils.addToUserCart([{ id: 1, quantity: 2 }, { id: 2, quantity: 3 }])
    expect(promise).to.be.promise

    request = @requests[0]
    expect(request.url).to.be.equal(CART_URL)
    expect(request.method).to.be.equal('POST')
    expect(request.async).to.be.true
    expect(request.requestHeaders).to.has.property('Wb-Api-Token', 'XXX')
    expect(request.requestHeaders).to.has.property('Content-Type', 'application/json;charset=utf-8')
    expect(request.requestBody).to.be.equal('{"cartItems":[{"skuProfileId":1,"quantity":2},{"skuProfileId":2,"quantity":3}]}')

  it 'should trigger "cart-changed" event when items successfully added to cart', ->
    setLoginContext()
    stub = sinon.stub()
    EventBroker.subscribeEvent('cart-changed', stub)

    cartUtils.addToUserCart([id: 1, quantity: 2])

    respondSuccess.call(@)

    expect(stub).to.have.been.calledWith(JSON.parse(ADD_TO_CART_SUCCESS_RESPONSE))
        .and.to.be.calledOnce

    EventBroker.unsubscribeEvent('cart-changed', stub)

  respondSuccess = () ->
    request = @requests[0]
    request.respond(200, { "Content-Type": "application/json" }, ADD_TO_CART_SUCCESS_RESPONSE)

  setLoginContext = () ->
    utils.getApiToken.returns('XXX')
    utils.isLoggedIn.returns(yes)
