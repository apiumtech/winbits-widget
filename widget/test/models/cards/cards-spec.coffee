'use strict'

Cards =  require 'models/cards/cards'
utils = require 'lib/utils'
EventBroker = Chaplin.EventBroker
$ = Winbits.$

describe 'CardsSpec', ->

  before ->
    sinon.stub(utils, 'getApiToken').returns('XXX')
    sinon.stub(utils, 'isLoggedIn').returns(yes)
    sinon.stub(utils, 'getCurrentVerticalId').returns(1)

  after ->
    utils.getApiToken.restore()
    utils.isLoggedIn.restore()
    utils.getCurrentVerticalId.restore()

  beforeEach ->
    @model = new Cards
    @xhr = sinon.useFakeXMLHttpRequest()
    requests = @requests = []
    @xhr.onCreate = (xhr) -> requests.push(xhr)

  afterEach ->
    @model.dispose()
    @xhr.restore()

  it 'should has correct default config', ->
    expect(@model.url).to.match(/\/orders\/card-subscription\.json$/)
    expect(@model.needsAuth).to.be.true

  it 'should fetch card subscriptions', ->
    @model.fetch()

    request = @requests[0]
    expect(request.url).to.be.equal(@model.url)
    expect(request.method).to.be.equal('GET')
    expect(request.async).to.be.true
    expect(request.requestHeaders).to.has.property('Wb-Api-Token', 'XXX')

  it 'should parse fetched response', ->
    @model.fetch()

    request = @requests[0]
    request.respond(200, 'Content-Type': 'application/json', '{"meta":{},"response":[{"cardInfo":{}}]}')

    expect(@model.get('cards')).to.be.deep.eql([{ cardInfo: {} }])

  it 'should fetch model when "cards-changed" event is published', ->
    sinon.stub(@model, 'fetch')
    EventBroker.publishEvent('cards-changed')

    expect(@model.fetch).to.has.been.calledOnce
