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

  afterEach ->
    utils.ajaxRequest.restore?()
    utils.showMessageModal.restore?()
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
    expect(cartTotal).to.be.equal(30)

  it.skip 'should has accessor for computed property cartSaving', ->
    cartSaving = @model.cartSaving()
    expect(@model.accessors).to.contain('cartSaving')

  it 'should has accessor for computed property cartPercentageSaved', ->
    cartPercentageSaved = @model.cartPercentageSaved()
    expect(@model.accessors).to.contain('cartPercentageSaved')
    expect(cartPercentageSaved).to.be.equal(70)

  it 'cartPercentageSaved should be zero if no itemsTotal is zero', ->
    @model.set(itemsTotal: 0)

    cartPercentageSaved = @model.cartPercentageSaved()
    expect(cartPercentageSaved).to.be.equal(0)

  it 'should request checkout service with correct options', ->
    sinon.stub(utils, 'ajaxRequest')

    @model.requestCheckout()
    expect(utils.ajaxRequest).to.has.been.calledWithMatch(new RegExp('/orders/checkout\.json$'))
        .and.to.has.been.calledOnce
    ajaxOptions = utils.ajaxRequest.firstCall.args[1]
    expect(ajaxOptions).to.be.an('object')
        .and.to.has.property('type', 'POST')
    expect(ajaxOptions).to.has.property('headers').eql('Wb-Api-Token': 'XXX')
    expect(ajaxOptions).to.has.property('data', '{"verticalId":1}')

  it 'should show message if trying to checkout empty cart', ->
    @model.set(itemsCount: 0)
    sinon.stub(utils, 'showMessageModal')

    @model.requestCheckout()
    expect(utils.showMessageModal).to.has.been.calledOnce
