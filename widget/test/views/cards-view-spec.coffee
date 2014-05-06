'use strict'

CardsView =  require 'views/cards/cards-view'
$ = Winbits.$

describe 'CardsViewSpec', ->

  beforeEach ->
    sinon.spy($.fn, 'changeBox')
    sinon.spy($.fn, 'carouselSwiper')
    @view = new CardsView

  afterEach ->
    @view.dispose()
    $.fn.changeBox.restore()
    $.fn.carouselSwiper.restore()

  it 'should be rendered', ->
    expect(@view.$('.block-carrusel')).to.existExact(1)
    expect(@view.$('.creditCardAdd')).to.existExact(1)
    expect(@view.$('.carruselSCC-div')).to.exist

  it 'should apply changeBox plugin', ->
    expect($.fn.changeBox).to.has.been.calledOnce
    $chain = $.fn.changeBox.firstCall.returnValue
    expect($chain).to.has.$class('block-carrusel')

  it 'should apply carrouselSwipper plugin', ->
    expect($.fn.carouselSwiper).to.has.been.calledOnce
    $chain = $.fn.carouselSwiper.firstCall.returnValue
    expect($chain).to.has.$class('block-carrusel')
