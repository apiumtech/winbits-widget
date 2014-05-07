'use strict'

CardsView =  require 'views/cards/cards-view'
Cards =  require 'models/cards/cards'
$ = Winbits.$

describe 'CardsViewSpec', ->

  beforeEach ->
    sinon.spy($.fn, 'changeBox')
    sinon.spy($.fn, 'carouselSwiper')
    @model = new Cards cards: [{ cardInfo: { cardData: {} } }]
    sinon.stub(@model, 'fetch')
    @view = new CardsView model: @model

  afterEach ->
    @view.render.restore?()
    @model.fetch.restore?()
    @view.dispose()
    @model.dispose()
    $.fn.changeBox.restore()
    $.fn.carouselSwiper.restore()

  it 'should be rendered', ->
    expect(@view.$('.block-carrusel')).to.existExact(1)
    expect(@view.$('.creditCardAdd')).to.existExact(1)

  it 'should apply changeBox plugin', ->
    expect($.fn.changeBox).to.has.been.calledOnce
    $chain = $.fn.changeBox.firstCall.returnValue
    expect($chain).to.has.$class('block-carrusel')

  it 'should apply carrouselSwipper plugin', ->
    expect($.fn.carouselSwiper).to.has.been.calledOnce
    $chain = $.fn.carouselSwiper.firstCall.returnValue
    expect($chain).to.has.$class('block-carrusel')

  it 'should render when model changes', ->
    sinon.spy(@view, 'render')

    @model.set('cards', [])

    expect(@view.render).to.has.been.calledOnce

  it 'should fetch model when initialized', ->
    expect(@model.fetch).to.has.been.calledOnce

  it 'should render no cards panel when empty cards are set on model', ->
    @model.set('cards', [])

    expect(@view.$('.wbc-no-cards-panel')).to.exist

  it 'should render cards when cards are set in model', ->
    @model.set('cards', [cardInfo:{ subscriptionId: 1, cardData: {} }])

    expect(@view.$('.block-slide')).to.exist
    expect(@view.$('.block-slide').first()).to.has.data('id', 1)
