'use strict'
CartView = require 'views/cart/cart-view'
Cart = require 'models/cart/cart'
utils = require 'lib/utils'
$ = Winbits.$

describe 'TransferFromVirtualToAssignedCartViewSpec', ->

  ASSIGNED_CART_URL = utils.getResourceURL('orders/assign-virtual-cart.json')
  ASSIGNED_CART_RESPONSE = '{"meta":{"status":200},"response":{"itemsTotal":20,"itemsCount":2,"bitsTotal":0,"shippingTotal":250,"cartDetails":[{"quantity":2,"skuProfile":{"id":1,"price":10,"fullPrice":100,"item":{"attributeLabel":"attributeLabel","name":"ItemGroupProfile","vertical":{"name":"Looq","logo":"http://dev.mylooq.com","id":2},"thumbnail":"http://urltoimage"},"attributes":[{"name":"attribute0","label":"label0","value":"value0","type":"TEXT"},{"name":"attribute2","label":"label2","value":"value2","type":"TEXT"},{"name":"attribute1","label":"label1","value":"value1","type":"TEXT"}],"mainAttribute":{"name":"attributeName","label":"attributeLabel","type":"TEXT","value":"attributeValue"},"vertical":{"name":"Looq","logo":"http://dev.mylooq.com","id":2}},"min":1,"max":100,"warnings":[]}],"paymentMethods":[{"id":2,"identifier":"cybersource.cc","maxAmount":100000,"minAmount":0.01,"displayOrder":1,"offline":false,"logo":null},{"id":3,"identifier":"cybersource.token","maxAmount":100000,"minAmount":0.01,"displayOrder":1,"offline":false,"logo":null},{"id":4,"identifier":"cybersource.msi.3","maxAmount":100000,"minAmount":0.01,"displayOrder":1,"offline":false,"logo":null},{"id":5,"identifier":"cybersource.msi.6","maxAmount":100000,"minAmount":0.01,"displayOrder":1,"offline":false,"logo":null},{"id":6,"identifier":"cybersource.msi.9","maxAmount":100000,"minAmount":0.01,"displayOrder":1,"offline":false,"logo":null},{"id":7,"identifier":"cybersource.msi.12","maxAmount":100000,"minAmount":0.01,"displayOrder":1,"offline":false,"logo":null},{"id":8,"identifier":"cybersource.msi.token.3","maxAmount":100000,"minAmount":0.01,"displayOrder":1,"offline":false,"logo":null},{"id":9,"identifier":"cybersource.msi.token.6","maxAmount":100000,"minAmount":0.01,"displayOrder":1,"offline":false,"logo":null},{"id":10,"identifier":"cybersource.msi.token.9","maxAmount":100000,"minAmount":0.01,"displayOrder":1,"offline":false,"logo":null},{"id":11,"identifier":"cybersource.msi.token.12","maxAmount":100000,"minAmount":0.01,"displayOrder":1,"offline":false,"logo":null},{"id":12,"identifier":"amex.cc","maxAmount":100000,"minAmount":0.01,"displayOrder":1,"offline":false,"logo":null},{"id":13,"identifier":"amex.msi.3","maxAmount":100000,"minAmount":0.01,"displayOrder":1,"offline":false,"logo":null},{"id":14,"identifier":"amex.msi.6","maxAmount":100000,"minAmount":0.01,"displayOrder":1,"offline":false,"logo":null},{"id":15,"identifier":"amex.msi.9","maxAmount":100000,"minAmount":0.01,"displayOrder":1,"offline":false,"logo":null},{"id":16,"identifier":"amex.msi.12","maxAmount":100000,"minAmount":0.01,"displayOrder":1,"offline":false,"logo":null},{"id":17,"identifier":"paypal.latam","maxAmount":40000,"minAmount":15,"displayOrder":3,"offline":false,"logo":null},{"id":18,"identifier":"paypal.msi","maxAmount":40000,"minAmount":15,"displayOrder":3,"offline":false,"logo":null},{"id":19,"identifier":"oxxo.bc","maxAmount":5000,"minAmount":20,"displayOrder":4,"offline":true,"logo":null},{"id":20,"identifier":"reference.hsbc","maxAmount":15000,"minAmount":20,"displayOrder":4,"offline":true,"logo":null},{"id":21,"identifier":"cybersource.msi","maxAmount":100000,"minAmount":0.01,"displayOrder":1,"offline":false,"logo":null},{"id":22,"identifier":"cybersource.msi.token","maxAmount":100000,"minAmount":0.01,"displayOrder":1,"offline":false,"logo":null},{"id":23,"identifier":"amex.msi","maxAmount":100000,"minAmount":0.01,"displayOrder":1,"offline":false,"logo":null},{"id":24,"identifier":"cybersource.token.msi.3","maxAmount":100000,"minAmount":0.01,"displayOrder":1,"offline":false,"logo":null},{"id":25,"identifier":"cybersource.token.msi.6","maxAmount":100000,"minAmount":0.01,"displayOrder":1,"offline":false,"logo":null},{"id":26,"identifier":"cybersource.token.msi.9","maxAmount":100000,"minAmount":0.01,"displayOrder":1,"offline":false,"logo":null},{"id":27,"identifier":"cybersource.token.msi.12","maxAmount":100000,"minAmount":0.01,"displayOrder":1,"offline":false,"logo":null}],"cashback":0}}'

  beforeEach ->
    @server = sinon.fakeServer.create()
    sinon.stub(utils, 'getApiToken').returns(undefined)
    @el = $('<li>', id: 'wbi-cart-holder').get(0)
    @view = new CartView container: @el
    @model = @view.model


  afterEach ->
    @server.restore()
    utils.getApiToken.restore()
    utils.isLoggedIn.restore?()
    utils.getVirtualCart.restore?()
    @model.fetch.restore?()
    @model.transferVirtualCart.restore?()
    @view.dispose()

  it 'fetch in initialize view when is virtual cart', ->
    sinon.stub(utils, 'isLoggedIn').returns(no)
    sinon.stub(@model, 'fetch').returns()
    sinon.stub(@model, 'transferVirtualCart').returns()
    @view.restoreCart()
    expect(@model.transferVirtualCart).to.not.has.been.called
    expect(@model.fetch).to.has.been.calledOnce

  it 'fetch in initialize view when is logged user', ->
    sinon.stub(utils, 'isLoggedIn').returns(yes)
    sinon.stub(utils, 'getVirtualCart').returns("[]")
    sinon.stub(@model, 'fetch').returns()
    sinon.stub(@model, 'transferVirtualCart').returns()
    @view.restoreCart()
    expect(@model.transferVirtualCart).to.not.has.been.called
    expect(@model.fetch).to.has.been.calledOnce

  it 'transfer virtual cart in initialize view when is logged user', ->
    sinon.stub(utils, 'isLoggedIn').returns(yes)
    sinon.stub(utils, 'getVirtualCart').returns('[{"2":1}]')
    sinon.stub(@model, 'fetch').returns()
    sinon.stub(@view, 'successTransferVirtualCart')
    sinon.stub(@model, 'transferVirtualCart').returns TestUtils.promises.resolved
    @view.restoreCart()
    expect(@view.successTransferVirtualCart).to.has.been.called
    expect(@model.fetch).to.not.has.been.calledOnce

  it 'transfer virtual cart params', ->
    sinon.stub(utils, 'isLoggedIn').returns(yes)
    sinon.stub(utils, 'getVirtualCart').returns('[{"2":1}]')
    @view.restoreCart()
    expect(@server.requests[1].method).to.be.equal 'POST'
    expect(@server.requests[1].url).to.be.equal ASSIGNED_CART_URL

  it 'transfer virtual cart when have a success response', ->
    sinon.stub(utils, 'isLoggedIn').returns(yes)
    sinon.stub(utils, 'getVirtualCart').returns('[{"2":1}]')
    sinon.stub(@model, 'fetch').returns()
    sinon.stub(@view, 'successTransferVirtualCart')
    @view.restoreCart()
    @server.requests[1].respond(200, {"Content-Type":"aplication/json"},ASSIGNED_CART_RESPONSE)
    expect(@server.requests[1].method).to.be.equal 'POST'
    expect(@model.fetch).to.not.has.been.calledOnce
    expect(@view.successTransferVirtualCart).to.has.been.called