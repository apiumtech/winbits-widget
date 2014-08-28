'use strict'

OrderTempOrderDetailsView = require 'views/checkout-temp/checkout-temp-order-details-sub-view'
Order = require 'models/checkout-temp/checkout-temp'
testUtils = require 'test/lib/test-utils'
$ = Winbits.$
_ = Winbits._
mediator = Winbits.Chaplin.mediator

describe 'CheckoutTempOrderDetailsViewSpec', ->

  beforeEach ->
    @loginData =
      id: 19
      apiToken: '6ue7zrBfNkxgNTvT4ReGpuh55yjNLRl6qEHiXMFyXFx6M3ymV21EaARwilDZK0zM'
      bitsBalance: 100
    mediator.data.set 'login-data', @loginData
    params ={"id":83,"email":"you_fhater@hotmail.com","orderNumber":"1406111659--83","itemsTotal":200,"shippingTotal":70,"bitsTotal":0,"total":200,"cashTotal":200,"status":"CHECKOUT","orderDetails":[{"id":74,"shippingAmount":0,"amount":200,"quantity":2,"sku":{"id":4,"name":"nameTo24","fullPrice":100,"price":100,"stock":77,"mainAttribute":{"name":"atributoName2","label":"atributoLabel","type":"TEXT","value":"AtributoLAbel"},"attributes":[{"name":"attribute1","label":"label1","value":"value1","type":"TEXT"}],"thumbnail":"http://d17puf58klsok4.cloudfront.net/Thumbnail/Thumbnail_2014392314_LEGO.jpg","vertical":{"id":2,"active":true,"baseUrl":"http://dev.mylooq.com","logo":null,"maxPerVertical":100000,"name":"Looq","order":0},"brand":{"id":1,"dateCreated":"2013-10-18T21:02:56-05:00","deleted":false,"description":"description","lastUpdated":"2013-10-18T21:02:56-05:00","logo":"http://www.google.com","name":"Brand","vertical":{"class":"Vertical","id":1}}},"requiresShipping":false,"min":1,"max":10},{"id":75,"shippingAmount":0,"amount":200,"quantity":2,"sku":{"id":4,"name":"nameTo24","fullPrice":100,"price":100,"stock":77,"mainAttribute":{"name":"atributoName2","label":"atributoLabel","type":"TEXT","value":"AtributoLAbel"},"attributes":[{"name":"attribute1","label":"label1","value":"value1","type":"TEXT"}],"thumbnail":"http://d17puf58klsok4.cloudfront.net/Thumbnail/Thumbnail_2014392314_LEGO.jpg","vertical":{"id":2,"active":true,"baseUrl":"http://dev.mylooq.com","logo":null,"maxPerVertical":100000,"name":"Looq","order":0},"brand":{"id":1,"dateCreated":"2013-10-18T21:02:56-05:00","deleted":false,"description":"description","lastUpdated":"2013-10-18T21:02:56-05:00","logo":"http://www.google.com","name":"Brand","vertical":{"class":"Vertical","id":1}}},"requiresShipping":false,"min":1,"max":10,"warnings":[{quantityRequired:3}]}],"paymentMethods":[{"id":2,"identifier":"cybersource.cc","maxAmount":100000,"minAmount":0.01,"displayOrder":1,"offline":false,"logo":null},{"id":3,"identifier":"cybersource.token","maxAmount":100000,"minAmount":0.01,"displayOrder":1,"offline":false,"logo":null},{"id":4,"identifier":"cybersource.msi.3","maxAmount":100000,"minAmount":0.01,"displayOrder":1,"offline":false,"logo":null},{"id":5,"identifier":"cybersource.msi.6","maxAmount":100000,"minAmount":0.01,"displayOrder":1,"offline":false,"logo":null},{"id":6,"identifier":"cybersource.msi.9","maxAmount":100000,"minAmount":0.01,"displayOrder":1,"offline":false,"logo":null},{"id":7,"identifier":"cybersource.msi.12","maxAmount":100000,"minAmount":0.01,"displayOrder":1,"offline":false,"logo":null},{"id":8,"identifier":"cybersource.msi.token.3","maxAmount":100000,"minAmount":0.01,"displayOrder":1,"offline":false,"logo":null},{"id":9,"identifier":"cybersource.msi.token.6","maxAmount":100000,"minAmount":0.01,"displayOrder":1,"offline":false,"logo":null},{"id":10,"identifier":"cybersource.msi.token.9","maxAmount":100000,"minAmount":0.01,"displayOrder":1,"offline":false,"logo":null},{"id":11,"identifier":"cybersource.msi.token.12","maxAmount":100000,"minAmount":0.01,"displayOrder":1,"offline":false,"logo":null},{"id":12,"identifier":"amex.cc","maxAmount":100000,"minAmount":0.01,"displayOrder":1,"offline":false,"logo":null},{"id":13,"identifier":"amex.msi.3","maxAmount":100000,"minAmount":0.01,"displayOrder":1,"offline":false,"logo":null},{"id":14,"identifier":"amex.msi.6","maxAmount":100000,"minAmount":0.01,"displayOrder":1,"offline":false,"logo":null},{"id":15,"identifier":"amex.msi.9","maxAmount":100000,"minAmount":0.01,"displayOrder":1,"offline":false,"logo":null},{"id":16,"identifier":"amex.msi.12","maxAmount":100000,"minAmount":0.01,"displayOrder":1,"offline":false,"logo":null},{"id":17,"identifier":"paypal.latam","maxAmount":40000,"minAmount":15,"displayOrder":3,"offline":false,"logo":null},{"id":18,"identifier":"paypal.msi","maxAmount":40000,"minAmount":15,"displayOrder":3,"offline":false,"logo":null},{"id":19,"identifier":"oxxo.bc","maxAmount":5000,"minAmount":20,"displayOrder":4,"offline":true,"logo":null},{"id":20,"identifier":"reference.hsbc","maxAmount":15000,"minAmount":20,"displayOrder":4,"offline":true,"logo":null},{"id":21,"identifier":"cybersource.msi","maxAmount":100000,"minAmount":0.01,"displayOrder":1,"offline":false,"logo":null},{"id":22,"identifier":"cybersource.msi.token","maxAmount":100000,"minAmount":0.01,"displayOrder":1,"offline":false,"logo":null},{"id":23,"identifier":"amex.msi","maxAmount":100000,"minAmount":0.01,"displayOrder":1,"offline":false,"logo":null},{"id":24,"identifier":"cybersource.token.msi.3","maxAmount":100000,"minAmount":0.01,"displayOrder":1,"offline":false,"logo":null},{"id":25,"identifier":"cybersource.token.msi.6","maxAmount":100000,"minAmount":0.01,"displayOrder":1,"offline":false,"logo":null},{"id":26,"identifier":"cybersource.token.msi.9","maxAmount":100000,"minAmount":0.01,"displayOrder":1,"offline":false,"logo":null},{"id":27,"identifier":"cybersource.token.msi.12","maxAmount":100000,"minAmount":0.01,"displayOrder":1,"offline":false,"logo":null}],"vertical":{"id":2,"url":"http://dev.mylooq.com"},"shippingOrder":null,"cashback":0,"estimatedDeliveryDate":null,"failedCartDetails":[{"thumbnail":"http://urltoimage","name":"ItemGroupProfile","brand":{"id":1,"dateCreated":"2013-10-18T21:02:56-05:00","deleted":false,"description":"description","lastUpdated":"2013-10-18T21:02:56-05:00","logo":"http://www.google.com","name":"Brand","vertical":{"class":"Vertical","id":1}},"attributes":[{"name":"attribute1","label":"label1","value":"value1","type":"TEXT"},{"name":"attribute2","label":"label2","value":"value2","type":"TEXT"},{"name":"attribute0","label":"label0","value":"value0","type":"TEXT"}],"mainAttribute":{"name":"attributeName","label":"attributeLabel","type":"TEXT","value":"attributeValue"},"vertical":{"id":2,"active":true,"baseUrl":"http://dev.mylooq.com","logo":null,"maxPerVertical":100000,"name":"Looq","order":0}},{"thumbnail":null,"name":"name1","brand":{"id":1,"dateCreated":"2013-10-18T21:02:56-05:00","deleted":false,"description":"description","lastUpdated":"2013-10-18T21:02:56-05:00","logo":"http://www.google.com","name":"Brand","vertical":{"class":"Vertical","id":1}},"attributes":[{"name":"attribute1","label":"label1","value":"value1","type":"TEXT"}],"mainAttribute":{"name":"atributoName","label":"atributoLabel","type":"TEXT","value":"AtributoLAbel"},"vertical":{"id":2,"active":true,"baseUrl":"http://dev.mylooq.com","logo":null,"maxPerVertical":100000,"name":"Looq","order":0}}]}
    @model = new Order params
    @view = new OrderTempOrderDetailsView model: @model
    @model = @view.model
    @view.render()

  afterEach ->
    @view.dispose()
    @model.set.restore?()
    @model.dispose()

  it 'should render', ->
    expect( @view.$ '.column1').to.exist
    expect( @view.$ '#wbi-order-detail-id-74').to.exist
    expect( @view.$ '.productOut').to.exist
    expect( @view.$ '.productUnavailable').to.exist

  it  'should render item quantity', ->
    $orderItem = @view.$('#wbi-order-detail-id-74')
    $itemQuantity = $orderItem.find('.wbc-item-quantity')
    expect($itemQuantity).to.existExact(1)
    expect($itemQuantity.val()).to.be.equal('2')


  it  'should render just one selected quantity option', ->
    $orderItem = @view.$('#wbi-order-detail-id-74')
    $selectedAttr = $orderItem.find('.wbc-item-quantity').children('[selected]')
    expect($selectedAttr).to.has.existExact(1)
    expect($selectedAttr).to.has.text('2')
    .and.to.has.attr('value', '2')

  it 'do update model', ->
    sinon.stub @model, 'set'
    $item1= @view.$('#wbi-order-detail-id-74')
    $selectQuantity= $($item1).find('.wbc-item-quantity')
    $selectQuantity.val 1
    $selectQuantity.change()
    expect( @model.set).has.been.called