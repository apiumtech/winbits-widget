HeaderView = require 'views/header/header-view'
Header = require 'models/header/header'

describe 'HeaderViewSpec', ->
  beforeEach ->
    headerData =
      currentVerticalId: 1
      verticalsData: [
        { id: 1, baseUrl: 'http://www.test-winbits.com', name: 'Winbits Test' },
        { id: 2, baseUrl: 'http://dev.mylooq.com', name: 'My LOOQ' }
      ]
    @model = new Header headerData
    @view = new HeaderView model: @model

  afterEach ->
    @view.dispose()
    @model.clear

  it 'shoul be rendered', ->
    expect(@view.$ '.widgetWinbitsHeader').to.exist

  it 'should render active verticals', ->
    expect(@view.$ 'a.wbc-vertical').to.exist
      .and.to.have.property 'length', 2

  it 'should render an active vertical correctly', ->
    activeVertical = @view.$('a.wbc-vertical').last()
    expect(activeVertical).to.exist
      .and.to.have.classes(['iconVertical-n', 'vertical2'])
      .and.to.have.attr('title', 'My LOOQ')
    expect(activeVertical).to.have.attr('href', 'http://dev.mylooq.com')

  it 'should render just one current active vertical', ->
    currentActiveVertical = @view.$ 'a.wbc-vertical.current'
    expect(currentActiveVertical).to.exist
      .and.to.have.property 'length', 1
    expect(currentActiveVertical).and.to.have.classes(['iconVertical-n', 'vertical1'])
      .and.to.have.attr('title', 'Winbits Test')
    expect(currentActiveVertical).to.have.attr('href', 'http://www.test-winbits.com')
