'use strict'

Cart = require 'models/cart/cart'
utils = require 'lib/utils'
$ = Winbits.$

describe 'CartSpec', ->

  CART_URL = utils.getResourceURL('orders/cart-items.json')

  before ->
    sinon.stub(utils, 'getApiToken').returns('XXX')
    sinon.stub(utils, 'isLoggedIn').returns(yes)
    sinon.stub(utils, 'getCurrentVerticalId').returns(1)

  after ->
    utils.getApiToken.restore()
    utils.isLoggedIn.restore()
    utils.getCurrentVerticalId.restore()

  beforeEach ->
    @xhr = sinon.useFakeXMLHttpRequest()
    requests = @requests = []
    @xhr.onCreate = (xhr) -> requests.push(xhr)
    @model = new Cart itemsTotal: 100, shippingTotal: 50, bitsTotal: 20, itemsCount: 2
    sinon.stub(@model, 'postToCheckoutApp')

  afterEach ->
    utils.ajaxRequest.restore?()
    utils.showMessageModal.restore?()
    @model.postToCheckoutApp.restore()
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

  it 'should has accessor for computed property cartTotal', ->
    cartTotal = @model.cartTotal()
    expect(@model.accessors).to.contain('cartTotal')
    expect(cartTotal).to.be.equal(130)

  it.skip 'should has accessor for computed property cartSaving', ->
    cartSaving = @model.cartSaving()
    expect(@model.accessors).to.contain('cartSaving')

  it.skip 'should has accessor for computed property cartPercentageSaved', ->
    cartPercentageSaved = @model.cartPercentageSaved()
    expect(@model.accessors).to.contain('cartPercentageSaved')
    expect(cartPercentageSaved).to.be.equal(70)

  it 'cartPercentageSaved should be zero if no itemsTotal is zero', ->
    @model.set(itemsTotal: 0)

    cartPercentageSaved = @model.cartPercentageSaved()
    expect(cartPercentageSaved).to.be.equal(0)

  it 'should request checkout service with correct options', ->
    sinon.stub(utils, 'ajaxRequest', (url, options) ->
      new $.Deferred().resolveWith(options.context, [response: id: 1]).promise()
    )

    result = @model.requestCheckout()
    expect(utils.ajaxRequest).to.has.been.calledWithMatch(/\/orders\/checkout\.json$/)
        .and.to.has.been.calledOnce
    ajaxOptions = utils.ajaxRequest.firstCall.args[1]
    expect(ajaxOptions).to.be.an('object')
        .and.to.has.property('type', 'POST')
    expect(ajaxOptions).to.has.property('context', @model)
    expect(ajaxOptions).to.has.property('headers').eql('Wb-Api-Token': 'XXX')
    expect(ajaxOptions).to.has.property('data', '{"verticalId":1}')
    expect(result).to.be.promise

  it.skip 'should redirect to checkout url if request succeeds', ->
    @model.requestCheckout()
    request = @requests[0]
    request.respond(200, 'Content-Type': 'application/json', '{"meta":{},"response":{"id":1}}')

    expect(window.location.assign).to.has.been.calledWithMatch(/https:\/\/checkout\w+\.winbits\.com\?orderId=1/)
        .and.to.has.been.calledOnce

  it 'should show message if trying to checkout empty cart', ->
    @model.set(itemsCount: 0)
    sinon.stub(utils, 'showMessageModal')

    result = @model.requestCheckout()
    expect(utils.showMessageModal).to.has.been.calledOnce
    expect(result).to.not.be.ok

  it 'should show error message if checkout request fails', ->
    sinon.stub(utils, 'showMessageModal')

    @model.requestCheckout()
    request = @requests[0]
    request.respond(400, {}, '{"meta":{"status":400,"message":"Error en checkout!"},"response":{}}')

    expect(utils.showMessageModal).to.has.been.calledWith('Error en checkout!')
        .and.to.has.been.calledOnce
