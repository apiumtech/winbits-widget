MailingView = require 'views/mailing/mailing-view'
MailingModel = require 'models/mailing/mailing'
utils = require 'lib/utils'
mediator = Winbits.Chaplin.mediator
$ = Winbits.$

describe 'MailingViewSpec', ->
  'use strict'

  before ->
    $.validator.setDefaults ignore: []

  after ->
    $.validator.setDefaults ignore: ':hidden'

  beforeEach ->
    subscriptions = [{"id":2,"name":"My Looq","active":false},{"id":3,"name":"Panda Sports","active":true},{"id":4,"name":"clickOnero","active":true}]
    @model = new MailingModel subscriptions: subscriptions, newsletterPeriodicity: 'weekly', newsletterFormat: 'separated'
    @view = new MailingView model: @model

  afterEach ->
    @view.dispose()
    @model.dispose()

  it 'mailing view should renderized', ->
    expect(@view.$('#wbi-mailing-form')).to.exist
    expect(@view.$('#wbi-subscription-verticals')).to.exist
    expect(@view.$('#wbi-how-to-received')).to.exist
    expect(@view.$('#wbi-how-often-to-received')).to.exist
    expect(@view.$('#wbi-mailing-btn')).to.exist

  it 'should call request success update subscriptions', ->
    sinon.stub(@view, 'doRequestSuscriptionsUpdate')
    sinon.stub(@model, 'requestUpdateSubscriptions').returns TestUtils.promises.resolved
    successStub = sinon.stub(@view, 'successSubscriptionsUpdate')
    errorStub = sinon.stub(@view, 'errorSubscriptionsUpdate')
    @view.$('#wbi-mailing-btn').click()

    expect(successStub).to.be.calledOnce
    expect(errorStub).to.not.be.calledOnce

  it 'should call request error update subscriptions', ->
    sinon.stub(@view, 'doRequestSuscriptionsUpdate')
    sinon.stub(@model, 'requestUpdateSubscriptions').returns TestUtils.promises.rejected
    successStub = sinon.stub(@view, 'successSubscriptionsUpdate')
    errorStub = sinon.stub(@view, 'errorSubscriptionsUpdate')
    @view.$('#wbi-mailing-btn').click()

    expect(successStub).to.not.be.calledOnce
    expect(errorStub).to.be.calledOnce