'use strict'
CheckoutTempView = require 'views/checkout-temp/checkout-temp-view'
CheckoutTemp = require 'models/checkout-temp/checkout-temp'
utils = require 'lib/utils'
$ = Winbits.$
mediator = Winbits.Chaplin.mediator

describe 'CheckoutTempViewSpec', ->

  beforeEach ->
    @server = sinon.fakeServer.create()
    params ={"id":83,"email":"you_fhater@hotmail.com","orderNumber":"1406111659--83","it.skipemsTotal":200,"shippingTotal":0,"bit.skipsTotal":0,"total":200,"cashTotal":200,"status":"CHECKOUT","orderDetails":[{"id":74,"shippingAmount":0,"amount":200,"quantit.skipy":2,"sku":{"id":4,"name":"nameTo24","fullPrice":100,"price":100,"stock":77,"mainAttribute":{"name":"atributoName2","label":"atributoLabel","type":"TEXT","value":"AtributoLAbel"},"attributes":[{"name":"attribute1","label":"label1","value":"value1","type":"TEXT"}],"thumbnail":"http://d17puf58klsok4.cloudfront.net/Thumbnail/Thumbnail_2014392314_LEGO.jpg","vertical":{"id":2,"active":true,"baseUrl":"http://dev.mylooq.com","logo":null,"maxPerVertical":100000,"name":"Looq","order":0},"brand":{"id":1,"dateCreated":"2013-10-18T21:02:56-05:00","deleted":false,"description":"description","lastUpdated":"2013-10-18T21:02:56-05:00","logo":"http://www.google.com","name":"Brand","vertical":{"class":"Vertical","id":1}}},"requiresShipping":false,"min":1,"max":10}],"paymentMethods":[{"id":2,"identifier":"cybersource.cc","maxAmount":100000,"minAmount":0.01,"displayOrder":1,"offline":false,"logo":null},{"id":3,"identifier":"cybersource.token","maxAmount":100000,"minAmount":0.01,"displayOrder":1,"offline":false,"logo":null},{"id":4,"identifier":"cybersource.msi.3","maxAmount":100000,"minAmount":0.01,"displayOrder":1,"offline":false,"logo":null},{"id":5,"identifier":"cybersource.msi.6","maxAmount":100000,"minAmount":0.01,"displayOrder":1,"offline":false,"logo":null},{"id":6,"identifier":"cybersource.msi.9","maxAmount":100000,"minAmount":0.01,"displayOrder":1,"offline":false,"logo":null},{"id":7,"identifier":"cybersource.msi.12","maxAmount":100000,"minAmount":0.01,"displayOrder":1,"offline":false,"logo":null},{"id":8,"identifier":"cybersource.msi.token.3","maxAmount":100000,"minAmount":0.01,"displayOrder":1,"offline":false,"logo":null},{"id":9,"identifier":"cybersource.msi.token.6","maxAmount":100000,"minAmount":0.01,"displayOrder":1,"offline":false,"logo":null},{"id":10,"identifier":"cybersource.msi.token.9","maxAmount":100000,"minAmount":0.01,"displayOrder":1,"offline":false,"logo":null},{"id":11,"identifier":"cybersource.msi.token.12","maxAmount":100000,"minAmount":0.01,"displayOrder":1,"offline":false,"logo":null},{"id":12,"identifier":"amex.cc","maxAmount":100000,"minAmount":0.01,"displayOrder":1,"offline":false,"logo":null},{"id":13,"identifier":"amex.msi.3","maxAmount":100000,"minAmount":0.01,"displayOrder":1,"offline":false,"logo":null},{"id":14,"identifier":"amex.msi.6","maxAmount":100000,"minAmount":0.01,"displayOrder":1,"offline":false,"logo":null},{"id":15,"identifier":"amex.msi.9","maxAmount":100000,"minAmount":0.01,"displayOrder":1,"offline":false,"logo":null},{"id":16,"identifier":"amex.msi.12","maxAmount":100000,"minAmount":0.01,"displayOrder":1,"offline":false,"logo":null},{"id":17,"identifier":"paypal.latam","maxAmount":40000,"minAmount":15,"displayOrder":3,"offline":false,"logo":null},{"id":18,"identifier":"paypal.msi","maxAmount":40000,"minAmount":15,"displayOrder":3,"offline":false,"logo":null},{"id":19,"identifier":"oxxo.bc","maxAmount":5000,"minAmount":20,"displayOrder":4,"offline":true,"logo":null},{"id":20,"identifier":"reference.hsbc","maxAmount":15000,"minAmount":20,"displayOrder":4,"offline":true,"logo":null},{"id":21,"identifier":"cybersource.msi","maxAmount":100000,"minAmount":0.01,"displayOrder":1,"offline":false,"logo":null},{"id":22,"identifier":"cybersource.msi.token","maxAmount":100000,"minAmount":0.01,"displayOrder":1,"offline":false,"logo":null},{"id":23,"identifier":"amex.msi","maxAmount":100000,"minAmount":0.01,"displayOrder":1,"offline":false,"logo":null},{"id":24,"identifier":"cybersource.token.msi.3","maxAmount":100000,"minAmount":0.01,"displayOrder":1,"offline":false,"logo":null},{"id":25,"identifier":"cybersource.token.msi.6","maxAmount":100000,"minAmount":0.01,"displayOrder":1,"offline":false,"logo":null},{"id":26,"identifier":"cybersource.token.msi.9","maxAmount":100000,"minAmount":0.01,"displayOrder":1,"offline":false,"logo":null},{"id":27,"identifier":"cybersource.token.msi.12","maxAmount":100000,"minAmount":0.01,"displayOrder":1,"offline":false,"logo":null}],"vertical":{"id":2,"url":"http://dev.mylooq.com"},"shippingOrder":null,"cashback":0,"estimatedDeliveryDate":null,"failedCartDetails":[{"thumbnail":"http://urltoimage","name":"ItemGroupProfile","brand":{"id":1,"dateCreated":"2013-10-18T21:02:56-05:00","deleted":false,"description":"description","lastUpdated":"2013-10-18T21:02:56-05:00","logo":"http://www.google.com","name":"Brand","vertical":{"class":"Vertical","id":1}},"attributes":[{"name":"attribute1","label":"label1","value":"value1","type":"TEXT"},{"name":"attribute2","label":"label2","value":"value2","type":"TEXT"},{"name":"attribute0","label":"label0","value":"value0","type":"TEXT"}],"mainAttribute":{"name":"attributeName","label":"attributeLabel","type":"TEXT","value":"attributeValue"},"vertical":{"id":2,"active":true,"baseUrl":"http://dev.mylooq.com","logo":null,"maxPerVertical":100000,"name":"Looq","order":0}},{"thumbnail":null,"name":"name1","brand":{"id":1,"dateCreated":"2013-10-18T21:02:56-05:00","deleted":false,"description":"description","lastUpdated":"2013-10-18T21:02:56-05:00","logo":"http://www.google.com","name":"Brand","vertical":{"class":"Vertical","id":1}},"attributes":[{"name":"attribute1","label":"label1","value":"value1","type":"TEXT"}],"mainAttribute":{"name":"atributoName","label":"atributoLabel","type":"TEXT","value":"AtributoLAbel"},"vertical":{"id":2,"active":true,"baseUrl":"http://dev.mylooq.com","logo":null,"maxPerVertical":100000,"name":"Looq","order":0}}]}
    @model = new CheckoutTemp params
    @view = new CheckoutTempView model:@model


  afterEach ->
    @server.restore()
    @model.postToCheckoutApp.restore?()
    utils.redirectToLoggedInHome.restore?()
    @view.dispose()

  it 'checkout temp is rendered', ->
    expect(@view.$ '#wbi-checkout-temp-table-div').to.has.id('wbi-checkout-temp-table-div')
      .and.to.has.$class('dataTable')
    expect(@view.$ 'div.resumeCheckoutTable').to.exist
    expect(@view.$ 'div.wrapper.titleTable').to.exist
    expect(@view.$ '#wbi-return-site-btn').to.exist
    expect(@view.$ '#wbi-post-checkout-btn').to.exist

  it 'should call to checkout app', ->
    sinon.stub @model, 'postToCheckoutApp'
    @view.$('#wbi-post-checkout-btn').click()
    expect(@model.postToCheckoutApp).to.has.been.calledOnce

  it 'should call back to vertical', ->
    sinon.stub utils, 'redirectToLoggedInHome'
    @view.$('#wbi-return-site-btn').click()
    expect(utils.redirectToLoggedInHome).to.has.been.calledOnce