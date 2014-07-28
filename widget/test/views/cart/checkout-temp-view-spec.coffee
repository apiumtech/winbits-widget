'use strict'
CheckoutTempView = require 'views/checkout-temp/checkout-temp-view'
CheckoutTemp = require 'models/checkout-temp/checkout-temp'
utils = require 'lib/utils'
$ = Winbits.$
mediator = Winbits.Chaplin.mediator

describe 'CheckoutTempViewSpec', ->

  RESPONSE_SUCCESS_DELETE_ITEM = '{"meta":{"status":200},"response":{"id":116,"email":"you_fhater@hotmail.com","orderNumber":"1407221155--116","itemsTotal":200,"shippingTotal":250,"bitsTotal":0,"total":450,"cashTotal":450,"status":"CHECKOUT","orderDetails":[{"id":103,"shippingAmount":0,"amount":200,"quantity":2,"sku":{"id":4,"name":"nameTo24","fullPrice":100,"price":100,"stock":75,"mainAttribute":{"name":"atributoName2","label":"atributoLabel","type":"TEXT","value":"AtributoLAbel"},"attributes":[{"name":"attribute1","label":"label1","value":"value1","type":"TEXT"}],"thumbnail":"http://d17puf58klsok4.cloudfront.net/Thumbnail/Thumbnail_2014392314_LEGO.jpg","vertical":{"id":2,"active":true,"baseUrl":"http://dev.mylooq.com","logo":null,"maxPerVertical":100000,"name":"Looq","order":0},"brand":{"id":1,"dateCreated":"2013-10-18T21:02:56-05:00","deleted":false,"description":"description","lastUpdated":"2013-10-18T21:02:56-05:00","logo":"http://www.google.com","name":"Brand","vertical":{"class":"Vertical","id":1}}},"requiresShipping":false,"min":1,"max":10}],"paymentMethods":[{"id":2,"identifier":"cybersource.cc","maxAmount":100000,"minAmount":0.01,"displayOrder":1,"offline":false,"logo":null},{"id":3,"identifier":"cybersource.token","maxAmount":100000,"minAmount":0.01,"displayOrder":1,"offline":false,"logo":null},{"id":4,"identifier":"cybersource.msi.3","maxAmount":100000,"minAmount":0.01,"displayOrder":1,"offline":false,"logo":null},{"id":5,"identifier":"cybersource.msi.6","maxAmount":100000,"minAmount":0.01,"displayOrder":1,"offline":false,"logo":null},{"id":6,"identifier":"cybersource.msi.9","maxAmount":100000,"minAmount":0.01,"displayOrder":1,"offline":false,"logo":null},{"id":7,"identifier":"cybersource.msi.12","maxAmount":100000,"minAmount":0.01,"displayOrder":1,"offline":false,"logo":null},{"id":8,"identifier":"cybersource.msi.token.3","maxAmount":100000,"minAmount":0.01,"displayOrder":1,"offline":false,"logo":null},{"id":9,"identifier":"cybersource.msi.token.6","maxAmount":100000,"minAmount":0.01,"displayOrder":1,"offline":false,"logo":null},{"id":10,"identifier":"cybersource.msi.token.9","maxAmount":100000,"minAmount":0.01,"displayOrder":1,"offline":false,"logo":null},{"id":11,"identifier":"cybersource.msi.token.12","maxAmount":100000,"minAmount":0.01,"displayOrder":1,"offline":false,"logo":null},{"id":12,"identifier":"amex.cc","maxAmount":100000,"minAmount":0.01,"displayOrder":1,"offline":false,"logo":null},{"id":13,"identifier":"amex.msi.3","maxAmount":100000,"minAmount":0.01,"displayOrder":1,"offline":false,"logo":null},{"id":14,"identifier":"amex.msi.6","maxAmount":100000,"minAmount":0.01,"displayOrder":1,"offline":false,"logo":null},{"id":15,"identifier":"amex.msi.9","maxAmount":100000,"minAmount":0.01,"displayOrder":1,"offline":false,"logo":null},{"id":16,"identifier":"amex.msi.12","maxAmount":100000,"minAmount":0.01,"displayOrder":1,"offline":false,"logo":null},{"id":17,"identifier":"paypal.latam","maxAmount":40000,"minAmount":15,"displayOrder":3,"offline":false,"logo":null},{"id":18,"identifier":"paypal.msi","maxAmount":40000,"minAmount":15,"displayOrder":3,"offline":false,"logo":null},{"id":19,"identifier":"oxxo.bc","maxAmount":5000,"minAmount":20,"displayOrder":4,"offline":true,"logo":null},{"id":20,"identifier":"reference.hsbc","maxAmount":15000,"minAmount":20,"displayOrder":4,"offline":true,"logo":null},{"id":21,"identifier":"cybersource.msi","maxAmount":100000,"minAmount":0.01,"displayOrder":1,"offline":false,"logo":null},{"id":22,"identifier":"cybersource.msi.token","maxAmount":100000,"minAmount":0.01,"displayOrder":1,"offline":false,"logo":null},{"id":23,"identifier":"amex.msi","maxAmount":100000,"minAmount":0.01,"displayOrder":1,"offline":false,"logo":null},{"id":24,"identifier":"cybersource.token.msi.3","maxAmount":100000,"minAmount":0.01,"displayOrder":1,"offline":false,"logo":null},{"id":25,"identifier":"cybersource.token.msi.6","maxAmount":100000,"minAmount":0.01,"displayOrder":1,"offline":false,"logo":null},{"id":26,"identifier":"cybersource.token.msi.9","maxAmount":100000,"minAmount":0.01,"displayOrder":1,"offline":false,"logo":null},{"id":27,"identifier":"cybersource.token.msi.12","maxAmount":100000,"minAmount":0.01,"displayOrder":1,"offline":false,"logo":null}],"vertical":{"id":2,"url":"http://dev.mylooq.com"},"shippingOrder":null,"cashback":0,"estimatedDeliveryDate":null}}'
  RESPONSE_SUCCESS_CANCEL_ORDER = '{"meta":{"status":200},"response":{"id":143,"bitsTotal":0,"cashTotal":450,"dateCreated":"2014-07-23T12:31:14-05:00","itemsTotal":200,"lastUpdated":"2014-07-23T12:31:35-05:00","orderDetails":[{"class":"OrderDetail","id":154}],"orderNumber":"1407231231--143","orderPayments":[],"paidDate":null,"salesAgentId":null,"shippingOrder":null,"shippingTotal":250,"status":{"class":"OrderStatus","id":2},"total":450,"user":{"class":"User","id":154},"vertical":{"class":"Vertical","id":2}}}'

  beforeEach ->
    @server = sinon.fakeServer.create()
    params ={"id":116,"email":"you_fhater@hotmail.com","orderNumber":"1407221155--116","itemsTotal":220,"shippingTotal":250,"bitsTotal":0,"total":470,"cashTotal":470,"status":"CHECKOUT","orderDetails":[{"id":103,"shippingAmount":0,"amount":200,"quantity":2,"sku":{"id":4,"name":"nameTo24","fullPrice":100,"price":100,"stock":75,"mainAttribute":{"name":"atributoName2","label":"atributoLabel","type":"TEXT","value":"AtributoLAbel"},"attributes":[{"name":"attribute1","label":"label1","value":"value1","type":"TEXT"}],"thumbnail":"http://d17puf58klsok4.cloudfront.net/Thumbnail/Thumbnail_2014392314_LEGO.jpg","vertical":{"id":2,"active":true,"baseUrl":"http://dev.mylooq.com","logo":null,"maxPerVertical":100000,"name":"Looq","order":0},"brand":{"id":1,"dateCreated":"2013-10-18T21:02:56-05:00","deleted":false,"description":"description","lastUpdated":"2013-10-18T21:02:56-05:00","logo":"http://www.google.com","name":"Brand","vertical":{"class":"Vertical","id":1}}},"requiresShipping":false,"min":1,"max":10},{"id":104,"shippingAmount":0,"amount":20,"quantity":2,"sku":{"id":3,"name":"name1","fullPrice":100,"price":10,"stock":-1,"mainAttribute":{"name":"attributeName","label":"attributeLabel","type":"TEXT","value":"attributeValue"},"attributes":[{"name":"attribute1","label":"label1","value":"value1","type":"TEXT"},{"name":"attribute0","label":"label0","value":"value0","type":"TEXT"},{"name":"attribute2","label":"label2","value":"value2","type":"TEXT"}],"thumbnail":"http://urltoimage","vertical":{"id":2,"active":true,"baseUrl":"http://dev.mylooq.com","logo":null,"maxPerVertical":100000,"name":"Looq","order":0},"brand":{"id":1,"dateCreated":"2013-10-18T21:02:56-05:00","deleted":false,"description":"description","lastUpdated":"2013-10-18T21:02:56-05:00","logo":"http://www.google.com","name":"Brand","vertical":{"class":"Vertical","id":1}}},"requiresShipping":false,"min":1,"max":10}],"paymentMethods":[{"id":2,"identifier":"cybersource.cc","maxAmount":100000,"minAmount":0.01,"displayOrder":1,"offline":false,"logo":null},{"id":3,"identifier":"cybersource.token","maxAmount":100000,"minAmount":0.01,"displayOrder":1,"offline":false,"logo":null},{"id":4,"identifier":"cybersource.msi.3","maxAmount":100000,"minAmount":0.01,"displayOrder":1,"offline":false,"logo":null},{"id":5,"identifier":"cybersource.msi.6","maxAmount":100000,"minAmount":0.01,"displayOrder":1,"offline":false,"logo":null},{"id":6,"identifier":"cybersource.msi.9","maxAmount":100000,"minAmount":0.01,"displayOrder":1,"offline":false,"logo":null},{"id":7,"identifier":"cybersource.msi.12","maxAmount":100000,"minAmount":0.01,"displayOrder":1,"offline":false,"logo":null},{"id":8,"identifier":"cybersource.msi.token.3","maxAmount":100000,"minAmount":0.01,"displayOrder":1,"offline":false,"logo":null},{"id":9,"identifier":"cybersource.msi.token.6","maxAmount":100000,"minAmount":0.01,"displayOrder":1,"offline":false,"logo":null},{"id":10,"identifier":"cybersource.msi.token.9","maxAmount":100000,"minAmount":0.01,"displayOrder":1,"offline":false,"logo":null},{"id":11,"identifier":"cybersource.msi.token.12","maxAmount":100000,"minAmount":0.01,"displayOrder":1,"offline":false,"logo":null},{"id":12,"identifier":"amex.cc","maxAmount":100000,"minAmount":0.01,"displayOrder":1,"offline":false,"logo":null},{"id":13,"identifier":"amex.msi.3","maxAmount":100000,"minAmount":0.01,"displayOrder":1,"offline":false,"logo":null},{"id":14,"identifier":"amex.msi.6","maxAmount":100000,"minAmount":0.01,"displayOrder":1,"offline":false,"logo":null},{"id":15,"identifier":"amex.msi.9","maxAmount":100000,"minAmount":0.01,"displayOrder":1,"offline":false,"logo":null},{"id":16,"identifier":"amex.msi.12","maxAmount":100000,"minAmount":0.01,"displayOrder":1,"offline":false,"logo":null},{"id":17,"identifier":"paypal.latam","maxAmount":40000,"minAmount":15,"displayOrder":3,"offline":false,"logo":null},{"id":18,"identifier":"paypal.msi","maxAmount":40000,"minAmount":15,"displayOrder":3,"offline":false,"logo":null},{"id":19,"identifier":"oxxo.bc","maxAmount":5000,"minAmount":20,"displayOrder":4,"offline":true,"logo":null},{"id":20,"identifier":"reference.hsbc","maxAmount":15000,"minAmount":20,"displayOrder":4,"offline":true,"logo":null},{"id":21,"identifier":"cybersource.msi","maxAmount":100000,"minAmount":0.01,"displayOrder":1,"offline":false,"logo":null},{"id":22,"identifier":"cybersource.msi.token","maxAmount":100000,"minAmount":0.01,"displayOrder":1,"offline":false,"logo":null},{"id":23,"identifier":"amex.msi","maxAmount":100000,"minAmount":0.01,"displayOrder":1,"offline":false,"logo":null},{"id":24,"identifier":"cybersource.token.msi.3","maxAmount":100000,"minAmount":0.01,"displayOrder":1,"offline":false,"logo":null},{"id":25,"identifier":"cybersource.token.msi.6","maxAmount":100000,"minAmount":0.01,"displayOrder":1,"offline":false,"logo":null},{"id":26,"identifier":"cybersource.token.msi.9","maxAmount":100000,"minAmount":0.01,"displayOrder":1,"offline":false,"logo":null},{"id":27,"identifier":"cybersource.token.msi.12","maxAmount":100000,"minAmount":0.01,"displayOrder":1,"offline":false,"logo":null}],"vertical":{"id":2,"url":"http://dev.mylooq.com"},"shippingOrder":null,"cashback":0,"estimatedDeliveryDate":null,"failedCartDetails":[{"thumbnail":"http://urltoimage","name":"ItemGroupProfile","brand":{"id":1,"dateCreated":"2013-10-18T21:02:56-05:00","deleted":false,"description":"description","lastUpdated":"2013-10-18T21:02:56-05:00","logo":"http://www.google.com","name":"Brand","vertical":{"class":"Vertical","id":1}},"attributes":[{"name":"attribute1","label":"label1","value":"value1","type":"TEXT"},{"name":"attribute0","label":"label0","value":"value0","type":"TEXT"},{"name":"attribute2","label":"label2","value":"value2","type":"TEXT"}],"mainAttribute":{"name":"attributeName","label":"attributeLabel","type":"TEXT","value":"attributeValue"},"vertical":{"id":2,"active":true,"baseUrl":"http://dev.mylooq.com","logo":null,"maxPerVertical":100000,"name":"Looq","order":0}},{"thumbnail":null,"name":"name1","brand":{"id":1,"dateCreated":"2013-10-18T21:02:56-05:00","deleted":false,"description":"description","lastUpdated":"2013-10-18T21:02:56-05:00","logo":"http://www.google.com","name":"Brand","vertical":{"class":"Vertical","id":1}},"attributes":[{"name":"attribute1","label":"label1","value":"value1","type":"TEXT"}],"mainAttribute":{"name":"atributoName","label":"atributoLabel","type":"TEXT","value":"AtributoLAbel"},"vertical":{"id":2,"active":true,"baseUrl":"http://dev.mylooq.com","logo":null,"maxPerVertical":100000,"name":"Looq","order":0}}]}
    @model = new CheckoutTemp params
    @view = new CheckoutTempView model:@model
    @clock = sinon.useFakeTimers()

  afterEach ->
    @clock.restore()
    @server.restore()
    @model.postToCheckoutApp.restore?()
    utils.redirectToLoggedInHome.restore?()
    utils.showMessageModal.restore?()
    @view.dispose()

  it 'checkout temp is rendered', ->
    expect(@view.$ '#wbi-checkout-temp-table-div').to.has.id('wbi-checkout-temp-table-div')
      .and.to.has.$class('dataTable')
    expect(@view.$ 'div.resumeCheckoutTable').to.exist
    expect(@view.$ 'div.wrapper.titleTable').to.exist
    expect(@view.$ '#wbi-return-site-btn').to.exist
    expect(@view.$ '#wbi-post-checkout-btn').to.exist

  it 'should call to checkout app success', ->
    sinon.stub @model, 'postToCheckoutApp'
    sinon.stub utils, 'showMessageModal'
    @view.$('#wbi-post-checkout-btn').click()
    @server.requests[0].respond(200, { "Content-Type": "application/json" }, RESPONSE_SUCCESS_DELETE_ITEM)
    expect(@model.postToCheckoutApp).to.has.been.calledOnce
    expect(utils.showMessageModal).to.has.not.been.called

  it 'should call to checkout app fail', ->
    sinon.stub @model, 'postToCheckoutApp'
    sinon.stub utils, 'showMessageModal'
    @view.$('#wbi-post-checkout-btn').click()
    @server.requests[0].respond(500, { "Content-Type": "application/json" }, '')
    expect(@model.postToCheckoutApp).to.has.not.been.called
    expect(utils.showMessageModal).to.has.been.calledOnce

  it 'should call back to vertical', ->
    sinon.stub utils, 'redirectToLoggedInHome'
    @view.$('#wbi-return-site-btn').click()
    expect(utils.redirectToLoggedInHome).to.has.been.calledOnce

  it.skip 'should expire order when time out', ->
    sinon.spy @view, 'expireOrderByTimeOut'
    sinon.stub utils, 'showMessageModal'
    @view.attach()
    @clock.tick(1800000)
    expect(@view.expireOrderByTimeOut).to.be.calledOnce

  it 'should delete item success when have more of one item', ->
    sinon.stub @view, 'doSuccessRequestDeleteOrderDetail'
    sinon.stub @view, 'doFailRequestDeleteOrderDetail'
    @view.doRequestDeleteOrderDetail(111)
    @server.requests[0].respond(200, { "Content-Type": "application/json" }, RESPONSE_SUCCESS_DELETE_ITEM)
    expect( @view.doSuccessRequestDeleteOrderDetail).has.been.calledOnce
    expect( @view.doFailRequestDeleteOrderDetail).has.not.been.called

  it 'should delete item error', ->
    sinon.stub @view, 'doSuccessRequestDeleteOrderDetail'
    sinon.stub @view, 'doFailRequestDeleteOrderDetail'
    @view.doRequestDeleteOrderDetail(111)
    @server.requests[0].respond(500, { "Content-Type": "application/json" }, '')
    expect( @view.doSuccessRequestDeleteOrderDetail).has.not.been.calledOnce
    expect( @view.doFailRequestDeleteOrderDetail).has.been.called


  it 'should delete last item success', ->
    sinon.stub @view, 'doSuccessRequestCancelOrder'
    sinon.stub @view, 'doFailRequestDeleteOrderDetail'
    @view.doRequestCancelOrder()
    @server.requests[0].respond(200, { "Content-Type": "application/json" }, RESPONSE_SUCCESS_CANCEL_ORDER)
    expect( @view.doSuccessRequestCancelOrder)
    expect( @view.doFailRequestDeleteOrderDetail).has.not.been.called

  it 'should delete last item error', ->
    sinon.stub @view, 'doSuccessRequestCancelOrder'
    sinon.stub @view, 'doFailRequestDeleteOrderDetail'
    @view.doRequestCancelOrder()
    @server.requests[0].respond(500, { "Content-Type": "application/json" }, '')
    expect( @view.doSuccessRequestCancelOrder).has.not.been.calledOnce
    expect( @view.doFailRequestDeleteOrderDetail).has.been.called