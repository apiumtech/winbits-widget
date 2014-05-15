'use strict'

CardsView =  require 'views/cards/cards-view'
Cards =  require 'models/cards/cards'
CardView = require 'views/cards/card-view'
EventBroker = Chaplin.EventBroker
$ = Winbits.$

describe 'CardsViewSpec', ->

  beforeEach ->
    @model = new Cards
    sinon.stub(@model, 'fetch')
    sinon.stub(@model, 'requestSetDefaultCard')
    sinon.stub(@model, 'getCardById').returns(cardInfo: cardData: { cardType: 'Visa' }, cardAddress: {})
    @view = new CardsView model: @model

  afterEach ->
    @view.render.restore?()
    @view.showNewCardView.restore?()
    @view.editCard.restore?()
    @view.showEditCardView.restore?()
    @view.deleteCard.restore?()
    @view.dispose()
    @model.fetch.restore()
    @model.requestSetDefaultCard.restore()
    @model.getCardById.restore()
    @model.dispose()
    $.fn.changeBox.restore?()
    $.fn.carouselSwiper.restore?()
    $.fn.slideDown.restore?()
    $.fn.slideUp.restore?()

  it 'should be rendered without cards', ->
    expect(@view.$('#wbi-no-cards-panel')).to.existExact(1)
    expect(@view.$('#wbi-cards-carousel')).to.not.exist
    expect(@view.$('#wbi-new-card-link')).to.existExact(1)

  it 'should be rendered with cards', ->
    setModel.call(@)

    expect(@view.$('#wbi-cards-carousel')).to.existExact(1)
    expect(@view.$('#wbi-new-card-link')).to.existExact(1)
    expect(@view.$('.wbc-card')).to.exist

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

  it 'should render no cards panel when model is cleared', ->
    @model.clear()

    expect(@view.$('#wbi-no-cards-panel')).to.exist

  it 'should render non default card', ->
    setModel.call(@)

    $card = @view.$('.wbc-card').first()
    expect($card).to.has.data('id', 5)
    expect($card.find('.carruselSCC-div')).to.not.has.$class('carruselSCC-selected')
    expect($card.find('.wbc-card-index')).to.has.$text('Tarjeta 1')
    expect($card.find('.wbc-card-type')).to.has.$text('Master Card,')
    expect($card.find('.wbc-card-number')).to.has.$text('12345')
    expect($card.find('.wbc-expiration-date')).to.has.$text('10/18')
    expect($card.find('.wbc-edit-card-link')).to.existExact(1)
    expect($card.find('.wbc-delete-card-link')).to.existExact(1)

  it 'should render default card', ->
    setModel.call(@)

    $card = @view.$('.wbc-card').last()
    expect($card).to.has.data('id', 10)
    expect($card).to.has.$class('carruselSCC-selected')

  it 'should request to set as default card when non default card is clicked', ->
    setModel.call(@)
    @model.requestSetDefaultCard.returns(TestUtils.promises.idle)
    $nonDefaultCard = @view.$('.wbc-card').first()

    $nonDefaultCard.click()
    expect(@model.requestSetDefaultCard).to.has.been.calledWith(5, @view)
        .and.to.has.been.calledOnce

  it 'should not request to set as default card when default card is clicked', ->
    setModel.call(@)
    $defaultCard = @view.$('.wbc-card').last()

    $defaultCard.click()
    expect(@model.requestSetDefaultCard).to.not.has.been.called

  it 'should set default card if request succeds', ->
    setModel.call(@)
    @model.requestSetDefaultCard.returns(getDefaultCardSolvedPromise.call(@))
    $nonDefaultCard = @view.$('.wbc-card').first()

    $nonDefaultCard.click()
    expect($nonDefaultCard).to.has.$class('carruselSCC-selected')
    expect(@view.$('.carruselSCC-selected')).to.existExact(1)

  it 'should show card view when new card link is clicked', ->
    sinon.spy(@view, 'showNewCardView')

    @view.$('#wbi-new-card-link').click()

    expect(@view.showNewCardView).to.has.been.calledOnce
    expect(@view.subview('new-card-view')).to.be.instanceof(CardView)

  it 'should slides up cards carousel & slides down new card view', ->
    sinon.spy($.fn, 'slideUp')
    sinon.spy($.fn, 'slideDown')
    @view.$('#wbi-new-card-link').click()

    expect($.fn.slideUp).to.has.been.calledOnce
    expect($.fn.slideUp.firstCall.returnValue).to.has.id('wbi-cards-carousel-view')
    expect($.fn.slideDown).to.has.been.calledOnce
    newCardView = @view.subview('new-card-view')
    expect($.fn.slideDown.firstCall.returnValue).to.be.equal(newCardView.$el)

  it 'should show view when "card-view-hidden" event is published', ->
    sinon.spy($.fn, 'slideDown')

    EventBroker.publishEvent('card-view-hidden')
    expect($.fn.slideDown).to.has.been.calledOnce
    expect($.fn.slideDown.firstCall.returnValue).to.be.equal(@view.$el)

  it 'should bind event on card edit links', ->
    sinon.spy(@view, 'editCard')
    sinon.stub(@view, 'showEditCardView')
    setModel.call(@)

    @view.$('.wbc-edit-card-link').click()

    expect(@view.editCard).to.has.been.calledTwice
    expect(@view.showEditCardView).to.has.been.calledTwice
    expect(@view.showEditCardView.firstCall).to.has.been.calledWith(5)
    expect(@view.showEditCardView.secondCall).to.has.been.calledWith(10)

  it 'showEditCardView should get card data from model', ->
    cardId = 5
    @view.showEditCardView(cardId)
    expect(@model.getCardById).to.has.been.calledWith(cardId)
        .and.to.has.been.calledOnce

  it 'should bind event on card delete links', ->
    sinon.spy(@view, 'deleteCard')
    sinon.stub(@view, 'confirmCardDeletion')
    setModel.call(@)

    @view.$('.wbc-delete-card-link').click()

    expect(@view.deleteCard).to.has.been.calledTwice
    expect(@view.confirmCardDeletion).to.has.been.calledTwice
    expect(@view.confirmCardDeletion.firstCall).to.has.been.calledWith(5)
    expect(@view.confirmCardDeletion.secondCall).to.has.been.calledWith(10)

    @view.confirmCardDeletion.restore()

  it.skip 'confirmCardDeletion should show message to confirm card deletion', ->
    sinon.stub(utils, 'showConfirmationModal')
    cardId = 5
    @view.confirmCardDeletion(cardId)
    expect(utils.showConfirmationModal).to.has.been.calledWith('¿Estás seguro de que deseas eliminar esta tarjeta?')
        .and.to.has.been.calledOnce

  setModel = ->
    data = []
    data.push cardInfo:{ subscriptionId: '5', cardData: { cardType: 'Master Card', accountNumber: '12345', expirationMonth: '10', expirationYear: '2018' }, cardAddress: {} }
    data.push cardInfo:{ subscriptionId: '10', cardData: { cardType: 'Visa', accountNumber: '67890', expirationMonth: '12', expirationYear: '2020' }, cardAddress: {}, cardPrincipal: yes }
    @model.set('cards', data)

  getDefaultCardSolvedPromise = ()->
    new $.Deferred().resolveWith(@view).promise()
