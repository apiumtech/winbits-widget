'use strict'

Card =  require 'models/cards/card'
utils = require 'lib/utils'
$ = Winbits.$

describe 'CardSpec', ->

  before ->
    sinon.stub(utils, 'getApiToken').returns('XXX')

  after ->
    utils.getApiToken.restore()

  beforeEach ->
    sinon.stub(utils, 'ajaxRequest').returns(TestUtils.promises.idle)
    @model = new Card

  afterEach ->
    @model.dispose()
    utils.ajaxRequest.restore()
    utils.showApiError.restore?()

  it 'should has correct default config', ->
    expect(@model.needsAuth).to.be.true

  it 'should request to save new credit card', ->
    cardData = firstName: 'Steve', accountNumber: '12345'
    context = {}
    @model.requestSaveNewCard(cardData, context)

    expect(utils.ajaxRequest).to.has.been.calledWithMatch('orders/card-subscription.json',
      type: 'POST'
      context: context
      data: '{"paymentInfo":{"firstName":"Steve","accountNumber":"12345"}}'
      headers:
        'Wb-Api-Token': 'XXX'
    ).and.to.has.been.calledOnce
    options = utils.ajaxRequest.firstCall.args[1]
    expect(options.context).to.be.equal(context)

  it 'should show error if request fails', ->
    sinon.stub(utils, 'showApiError')
    utils.ajaxRequest.returns(TestUtils.promises.rejected)

    @model.requestSaveNewCard({}, {})
    expect(utils.showApiError).to.has.been.calledOn(utils)
        .and.to.has.been.calledOnce
