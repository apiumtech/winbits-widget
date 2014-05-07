'use strict'

CardsView =  require 'views/cards/cards-view'
Cards =  require 'models/cards/cards'
$ = Winbits.$

describe 'CardsViewSpec', ->

  beforeEach ->
    @model = new Cards
    sinon.stub(@model, 'fetch')
    @view = new CardsView model: @model

  afterEach ->
    @view.render.restore?()
    @model.fetch.restore?()
    @view.dispose()
    @model.dispose()
    $.fn.changeBox.restore?()
    $.fn.carouselSwiper.restore?()

  it 'should be rendered without cards', ->
    expect(@view.$('#wbi-no-cards-panel')).to.existExact(1)
    expect(@view.$('#wbi-cards-carousel')).to.not.exist
    expect(@view.$('#wbi-new-card-link')).to.existExact(1)

  it 'should be rendered with cards', ->
    setModel.call(@)

    expect(@view.$('#wbi-cards-carousel')).to.existExact(1)
    expect(@view.$('#wbi-new-card-link')).to.existExact(1)
    expect(@view.$('.wbc-card')).to.exist

  it 'should apply changeBox plugin', ->
    sinon.spy($.fn, 'changeBox')

    setModel.call(@)

    expect($.fn.changeBox).to.has.been.calledOnce
    $chain = $.fn.changeBox.firstCall.returnValue
    expect($chain).to.has.id('wbi-cards-carousel')

  it 'should apply carrouselSwipper plugin', ->
    sinon.spy($.fn, 'carouselSwiper')

    setModel.call(@)

    expect($.fn.carouselSwiper).to.has.been.calledOnce
    $chain = $.fn.carouselSwiper.firstCall.returnValue
    expect($chain).to.has.id('wbi-cards-carousel')

  it 'should render when model changes', ->
    sinon.spy(@view, 'render')

    @model.set('cards', [])

    expect(@view.render).to.has.been.calledOnce

  it 'should fetch model when initialized', ->
    expect(@model.fetch).to.has.been.calledOnce

  it 'should render no cards panel when empty cards are set on model', ->
    @model.set('cards', [])

    expect(@view.$('#wbi-no-cards-panel')).to.exist

  it 'should render cards when cards are set in model', ->
    @model.set('cards', [cardInfo:{ subscriptionId: 1, cardData: {} }])

    expect(@view.$('.wbc-card')).to.exist
    expect(@view.$('.wbc-card').first()).to.has.data('id', 1)

  setModel = -> @model.set('cards', [cardInfo:{ subscriptionId: 1, cardData: {} }])
