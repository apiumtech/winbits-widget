'use strict'

cartUtils = require 'lib/cart-utils'
utils = require 'lib/utils'
EventBroker = Chaplin.EventBroker
$ = Winbits.$
addToCartErrors =
  ORDE001: 'No se encuentra el producto'
  ORDE002: 'No se encuentra el producto'
  ORDE003: 'No se encuentra el producto'
  ORDE004: 'Producto agotado'
  ORDE005: 'Producto excedido'
  ORDE006: 'Máximo de compra'
  ORDE007: 'Mínimo de compra'
  ORDE009: 'Máximo por sitio'
  ORDE010: 'Máximo por cliente'
  ORDE011: 'Máximo de compra'
  ORDE037: 'Producto agotado'
  ORDE038: 'Producto excedido'

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
    @requests = []
    @xhr.onCreate = $.proxy(((xhr) -> @requests.push(xhr)), @)
    sinon.spy(utils, 'ajaxRequest')
    sinon.stub(utils, 'saveVirtualCart')
    sinon.stub(utils, 'showMessageModal')

  afterEach ->
    @xhr.restore()
    utils.ajaxRequest.restore()
    utils.showMessageModal.restore()
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

  it 'validate references in cart-items',  ->
    expect(cartUtils.validateReference([{id:1, quantity:2, references:['asdasdas']},{id:1, quantity:2}])).is.equals yes
    expect(cartUtils.validateReference([{id:1, quantity:2, references:['asdasdas']}])).is.equals yes
    expect(cartUtils.validateReference([{id:1, quantity:2},{id:1, quantity:2}])).is.equals no
    expect(cartUtils.validateReference([{id:1, quantity:2}])).is.equals no


  _.each addToCartErrors, (title, code) ->
    it "should show error message if add to virtual cart fails: #{code}", ->
      cartUtils.addToVirtualCart({ id: 1, quantity: 2 })
      expectedOptions =
        icon: 'iconFont-info'
        title: title

      respondError.call(@, code)
      expect(utils.showMessageModal)
        .to.has.been.calledWithMatch(sinon.match.any, expectedOptions)

  _.each addToCartErrors, (title, code) ->
    it "should show error message if add to user cart fails: #{code}", ->
      setLoginContext()
      cartUtils.addToUserCart({ id: 1, quantity: 2 })
      expectedOptions =
        icon: 'iconFont-info'
        title: title

      respondError.call(@, code)
      expect(utils.showMessageModal)
        .to.has.been.calledWithMatch(sinon.match.any, expectedOptions)

  respondSuccess = ->
    request = @requests[0]
    request.respond(200, { 'Content-Type': 'application/json' },
      ADD_TO_CART_SUCCESS_RESPONSE)

  respondError = (code) ->
    request = @requests[0]
    request.respond(400, { 'Content-Type': 'application/json' },
      '{"meta":{"code":"'.concat(code).concat('"},"response":{}}'))

  setLoginContext = ->
    utils.getApiToken.returns('XXX')
    utils.isLoggedIn.returns(yes)
