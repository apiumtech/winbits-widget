'use strict'

TransferCartErrorView = require 'views/transfer-cart-errors/transfer-cart-errors-view'
TransferCartError = require 'models/transfer-cart-errors/transfer-cart-errors'
cartUtils = require 'lib/cart-utils'
utils = require 'lib/utils'
mediator = Winbits.Chaplin.mediator
$ = Winbits.$
_ = Winbits._

describe 'TransferCartErrorsViewSpec', ->

  RESPONSE_TRANFER_CART_ERRORS = {"itemsTotal":42,"itemsCount":6,"bitsTotal":0,"shippingTotal":250,"cartDetails":[{"quantity":4,"skuProfile":{"id":2,"price":10,"fullPrice":100,"item":{"attributeLabel":"atributoLabel","name":"name1","vertical":{"name":"Looq","logo":"http://dev.mylooq.com","id":2},"thumbnail":null},"attributes":[{"name":"attribute1","label":"label1","value":"value1","type":"TEXT"}],"mainAttribute":{"name":"atributoName","label":"atributoLabel","type":"TEXT","value":"AtributoLAbel"},"vertical":{"name":"Looq","logo":"http://dev.mylooq.com","id":2}},"min":1,"max":10,"warnings":[]},{"quantity":2,"skuProfile":{"id":1,"price":1,"fullPrice":100,"item":{"attributeLabel":"attributeLabel","name":"ItemGroupProfile","vertical":{"name":"Looq","logo":"http://dev.mylooq.com","id":2},"thumbnail":"http://urltoimage"},"attributes":[{"name":"attribute2","label":"label2","value":"value2","type":"TEXT"},{"name":"attribute0","label":"label0","value":"value0","type":"TEXT"},{"name":"attribute1","label":"label1","value":"value1","type":"TEXT"}],"mainAttribute":{"name":"attributeName","label":"attributeLabel","type":"TEXT","value":"attributeValue"},"vertical":{"name":"Looq","logo":"http://dev.mylooq.com","id":2}},"min":1,"max":2,"warnings":[{"quantityRequired":4}]}],"paymentMethods":[{"id":2,"identifier":"cybersource.cc","maxAmount":100000,"minAmount":0.01,"displayOrder":1,"offline":false,"logo":null},{"id":3,"identifier":"cybersource.token","maxAmount":100000,"minAmount":0.01,"displayOrder":1,"offline":false,"logo":null},{"id":4,"identifier":"cybersource.msi.3","maxAmount":100000,"minAmount":0.01,"displayOrder":1,"offline":false,"logo":null},{"id":5,"identifier":"cybersource.msi.6","maxAmount":100000,"minAmount":0.01,"displayOrder":1,"offline":false,"logo":null},{"id":6,"identifier":"cybersource.msi.9","maxAmount":100000,"minAmount":0.01,"displayOrder":1,"offline":false,"logo":null},{"id":7,"identifier":"cybersource.msi.12","maxAmount":100000,"minAmount":0.01,"displayOrder":1,"offline":false,"logo":null},{"id":8,"identifier":"cybersource.msi.token.3","maxAmount":100000,"minAmount":0.01,"displayOrder":1,"offline":false,"logo":null},{"id":9,"identifier":"cybersource.msi.token.6","maxAmount":100000,"minAmount":0.01,"displayOrder":1,"offline":false,"logo":null},{"id":10,"identifier":"cybersource.msi.token.9","maxAmount":100000,"minAmount":0.01,"displayOrder":1,"offline":false,"logo":null},{"id":11,"identifier":"cybersource.msi.token.12","maxAmount":100000,"minAmount":0.01,"displayOrder":1,"offline":false,"logo":null},{"id":12,"identifier":"amex.cc","maxAmount":100000,"minAmount":0.01,"displayOrder":1,"offline":false,"logo":null},{"id":13,"identifier":"amex.msi.3","maxAmount":100000,"minAmount":0.01,"displayOrder":1,"offline":false,"logo":null},{"id":14,"identifier":"amex.msi.6","maxAmount":100000,"minAmount":0.01,"displayOrder":1,"offline":false,"logo":null},{"id":15,"identifier":"amex.msi.9","maxAmount":100000,"minAmount":0.01,"displayOrder":1,"offline":false,"logo":null},{"id":16,"identifier":"amex.msi.12","maxAmount":100000,"minAmount":0.01,"displayOrder":1,"offline":false,"logo":null},{"id":17,"identifier":"paypal.latam","maxAmount":40000,"minAmount":15,"displayOrder":3,"offline":false,"logo":null},{"id":18,"identifier":"paypal.msi","maxAmount":40000,"minAmount":15,"displayOrder":3,"offline":false,"logo":null},{"id":19,"identifier":"oxxo.bc","maxAmount":5000,"minAmount":20,"displayOrder":4,"offline":true,"logo":null},{"id":20,"identifier":"reference.hsbc","maxAmount":15000,"minAmount":20,"displayOrder":4,"offline":true,"logo":null},{"id":21,"identifier":"cybersource.msi","maxAmount":100000,"minAmount":0.01,"displayOrder":1,"offline":false,"logo":null},{"id":22,"identifier":"cybersource.msi.token","maxAmount":100000,"minAmount":0.01,"displayOrder":1,"offline":false,"logo":null},{"id":23,"identifier":"amex.msi","maxAmount":100000,"minAmount":0.01,"displayOrder":1,"offline":false,"logo":null},{"id":24,"identifier":"cybersource.token.msi.3","maxAmount":100000,"minAmount":0.01,"displayOrder":1,"offline":false,"logo":null},{"id":25,"identifier":"cybersource.token.msi.6","maxAmount":100000,"minAmount":0.01,"displayOrder":1,"offline":false,"logo":null},{"id":26,"identifier":"cybersource.token.msi.9","maxAmount":100000,"minAmount":0.01,"displayOrder":1,"offline":false,"logo":null},{"id":27,"identifier":"cybersource.token.msi.12","maxAmount":100000,"minAmount":0.01,"displayOrder":1,"offline":false,"logo":null}],"cashback":0,"failedCartDetails":[{"quantity":4,"skuProfile":{"id":4,"price":100,"fullPrice":100,"item":{"attributeLabel":"atributoLabel","name":"nameTo24","vertical":{"name":"Looq","logo":"http://dev.mylooq.com","id":2},"thumbnail":"http://d17puf58klsok4.cloudfront.net/Thumbnail/Thumbnail_2014392314_LEGO.jpg"},"attributes":[{"name":"attribute1","label":"label1","value":"value1","type":"TEXT"}],"mainAttribute":{"name":"atributoName2","label":"atributoLabel","type":"TEXT","value":"AtributoLAbel"},"vertical":{"name":"Looq","logo":"http://dev.mylooq.com","id":2}},"min":1,"max":10,"warnings":[]}]}

  beforeEach ->
    @model = new TransferCartError RESPONSE_TRANFER_CART_ERRORS
    @view = new TransferCartErrorView model: @model, autoAttach: no
    sinon.stub(@view, 'showAsModal')
    @view.attach()

  afterEach ->
    @view.deleteSuccess.restore?()
    cartUtils.deleteCartItem.restore?()
    cartUtils.showCartErrorMessage.restore?()
    utils.showMessageModal.restore?()
    utils.closeMessageModal.restore?()
    utils.redirectTo.restore?()
    utils.ajaxRequest.restore?()
    @view.showAsModal.restore?()
    @view.dispose()
    @model.dispose()

  it 'Tranfers Cart Errors renderized', ->
    expect(@view.$('form#bodyModal')).to.exist
    expect(@view.$('.wbc-delete-cart-item-btn')).to.exist
    expect(@view.$('td.preCheckout-c4').text()).equal 'Producto no disponible'

  it 'Tranfers Cart Errors with only incomplete items', ->
    @view.model.set('failedCartDetails', null)
    @view.render()
    expect(@view.$('.wbc-delete-cart-item-btn')).to.exist
    expect(@view.$('td.preCheckout-c4')).to.not.exist

  it 'Should to render confirm to delete item', ->
    @view.$('#item-id-1').find('.wbc-delete-cart-item-btn').click()

    expect(@view.$('#wbi-layer-div')).to.has.not.class('loader-hide')
    expect(@view.$('#wbi-layer-confirm')).to.has.not.class('loader-hide')
    expect(@view.$('#wbi-layer-load')).to.has.class('loader-hide')

  it 'Should do delete request in confirm layer and response success', ->
    sinon.stub(cartUtils, 'deleteCartItem').returns TestUtils.promises.resolved
    deleteSuccess = sinon.stub @view, 'deleteSuccess'

    @view.$('#item-id-1').find('.wbc-delete-cart-item-btn').click()
    @view.$('#wbi-confirm-delete-btn').click()

    expect(deleteSuccess).to.be.calledOnce

  it 'Should dont delete request in confirm layer and click in cancel', ->
    sinon.stub(cartUtils, 'deleteCartItem').returns TestUtils.promises.resolved
    deleteSuccess = sinon.stub @view, 'deleteSuccess'

    @view.$('#item-id-1').find('.wbc-delete-cart-item-btn').click()
    @view.$('#wbi-cancel-delete-btn').click()

    expect(deleteSuccess).to.be.not.called
    expect(@view.$('#wbi-layer-div')).to.has.class('loader-hide')
    expect(@view.$('#wbi-layer-confirm')).to.has.class('loader-hide')
    expect(@view.$('#wbi-layer-load')).to.has.class('loader-hide')

  it 'Should call do delete request in confirm layer and response error', ->

    sinon.stub(utils, 'ajaxRequest').returns TestUtils.promises.rejected
    deleteError = sinon.stub cartUtils, 'deleteCartItemFail'
    deleteSuccess = sinon.stub @view, 'deleteSuccess'

    @view.$('#item-id-1').find('.wbc-delete-cart-item-btn').click()
    @view.$('#wbi-confirm-delete-btn').click()

    expect(deleteSuccess).to.not.be.called
    expect(deleteError).to.be.calledOnce

  it 'Click in continue button', ->
    redirectTo = sinon.stub utils, 'closeMessageModal'
    @view.$('#wbi-continue-transfer-btn').click()
    expect(redirectTo).to.be.calledOnce


  it 'Click in continue button and go to checkout', ->
    redirectTo = sinon.stub utils, 'closeMessageModal'
    publishEvent = sinon.stub @view, 'publishEvent'
    mediator.data.set 'virtual-checkout', yes
    @view.$('#wbi-continue-transfer-btn').click()

    expect(redirectTo).to.not.be.called
    expect(publishEvent).to.be.calledOnce
