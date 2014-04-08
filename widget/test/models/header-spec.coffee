Header = require 'models/header/header'

describe 'HeaderSpec', ->
  beforeEach ->
    @model = new Header

  afterEach ->
    @model.parse.restore?()
    @model.set.restore?()
    @model.clear()

  it 'should parse & set data when initialized', ->
    data =
      currentVerticalId: 1
      verticalsData: [foo: 'bar']
    parseStub = sinon.stub(@model, 'parse').returns data
    setStub = sinon.stub @model, 'set'

    @model.initialize data

    expect(parseStub).to.be.calledWith(meta: { currentVerticalId: 1}, response: data.verticalsData)
      .and.to.be.calledOnce
    expect(setStub).to.be.calledOnce

  it 'should not parse nor set data when initialized with no data', ->
    verticalsData = [foo: 'bar']
    parseStub = sinon.spy @model, 'parse'
    setStub = sinon.spy @model, 'set'

    @model.initialize

    expect(parseStub).to.not.have.been.called
    expect(setStub).to.not.have.been.called

  it 'should parse data & find current vertical', ->
    data =
      meta: currentVerticalId: 1
      response: [
        { id: 1, baseUrl: 'dev.winbits-test.com' },
        { id: 2, baseUrl: 'dev.mylooq.com' }
      ]

    parsedData = @model.parse data

    expect(parsedData).to.have.keys('currentVertical', 'activeVerticals')
    expect(parsedData.currentVertical).to.be.deep.equal(id: 1, baseUrl: 'dev.winbits-test.com')
    expect(parsedData.activeVerticals).to.be.deep.equal(data.response)
