'use strict'

View = require 'views/base/view'
NewCardView = require 'views/cards/new-card-view'
EditCardView = require 'views/cards/edit-card-view'
Card = require 'models/cards/card'
utils = require 'lib/utils'
mediator = Winbits.Chaplin.mediator
$ = Winbits.$
DEFAULT_CARD_CLASS = 'carruselSCC-selected'

module.exports = class CardsView extends View
  container: '#wb-credit-cards'
  template: require './templates/cards'
  id: 'wbi-cards-carousel-view'
  className: 'ccCarrusel'

  initialize: ->
    super
    @listenTo @model, 'change', -> @render()
    @clickOnCardHandler = @delegate 'click', '.wbc-card', -> @onCardClick.apply(@, arguments)
    @delegate 'click', '#wbi-new-card-link', -> @showNewCardView.apply(@, arguments)
    @delegate 'click', '.wbc-edit-card-link', -> @editCard.apply(@, arguments)
    @delegate 'click', '.wbc-delete-card-link', -> @deleteCard.apply(@, arguments)
    @subscribeEvent 'card-view-hidden', @showCardsView
    @model.fetch()

  attach: ->
    super
    @$('#wbi-cards-carousel').carouselSwiper({
          optionsSwiper:{
            slideClass: 'block-slide',
            wrapperClass: 'block-wrapper',
            grabCursor: yes,
            useCSS3Transforms: no,
            cssWidthAndHeight: no,
            slidesPerView: 4
            },
          arrowLeft: '.iconFont-left',
          arrowRight: '.iconFont-right',
          slidesNum: 4,
          slideCSS: '.block-slide',
          initialSlide: '.carruselSCC-selected'
    })

  onCardClick: (e) ->
    e.stopPropagation()
    $card = $(e.currentTarget)
    if not $card.is(".#{DEFAULT_CARD_CLASS}")
      utils.showAjaxLoading()
      id = $card.data('id')
      @cardCandidate = $card
      @turnCardsClickEvent('off')
      @model.requestSetDefaultCard(id, @)
          .done(@setDefaultCardSucceds)
          .fail(@setDefaultCardError)
          .always(@setDefaultCardCompletes)
    @calculateArrows()

  setDefaultCardSucceds: ->
    @getDefaultCard().removeClass(DEFAULT_CARD_CLASS)
    @cardCandidate.addClass(DEFAULT_CARD_CLASS)

  setDefaultCardError: ->
    message = "Por el momento no es posible marcar como tarjeta principal, inténtalo más tarde"
    options = value: "Continuar", title:'Error', icon:'iconFont-info', onClosed: utils.redirectTo controller: 'home', action: 'index'
    utils.showMessageModal(message, options)

  setDefaultCardCompletes: ->
    @turnCardsClickEvent('on')
    utils.hideAjaxLoading()

  calculateArrows:->
    @$('.block-carrusel').removeArrows({
      arrowLeft: '.iconFont-left',
      arrowRight: '.iconFont-right',
      slidesNum: 4,
      slideCSS: '.block-slide'
    });

  getDefaultCard: ->
    @$(".wbc-card.#{DEFAULT_CARD_CLASS}")

  turnCardsClickEvent: (state) ->
    @$el[state]('click', '.wbc-card', @clickOnCardHandler)

  showNewCardView: ->
    newCard = @fillCardModelWithMain @model.get('cards')
    newCardView = new NewCardView model: newCard
    @subview('new-card-view', newCardView)
    @$el.slideUp()
    newCardView.$el.slideDown()
  
  fillCardModelWithMain:(cards) ->
    card = new Card()
    mainAddress = mediator.data.get 'main-address'
    if cards?.length == 0  and mainAddress isnt null
      cardData =
        firstName: mainAddress.firstName
        lastName: @obtainFullLastName(mainAddress.lastName, mainAddress.lastName2)
        street: mainAddress.street    
        number: mainAddress.externalNumber
        city: mainAddress.county
        state: mainAddress.state
        zipCode: mainAddress.zipCode
        phone: mainAddress.phone
      card = new Card cardData      
    card  
 
  obtainFullLastName:(lastName, lastName2) ->
    fullLastName = lastName
    if lastName2
      fullLastName = lastName + ' ' + lastName2
    fullLastName

  showCardsView: ->
    @$el.slideDown()

  editCard: (e) ->
    e.stopPropagation()
    e.preventDefault()
    cardId = @getClickedCardId(e)
    @showEditCardView(cardId)

  getClickedCardId: (e) ->
    $(e.currentTarget).closest('.wbc-card').data('id')

  showEditCardView: (cardId) ->
    card = @model.getCardById(cardId)
    card = new Card card.cardInfo
    editCardView = new EditCardView model: card
    @subview('edit-card-view', editCardView)
    @$el.slideUp()
    editCardView.$el.slideDown()

  deleteCard: (e) ->
    e.stopPropagation()
    cardId = @getClickedCardId(e)
    @confirmCardDeletion(cardId)

  confirmCardDeletion: (cardId) ->
    @cardIdToDelete = cardId
    options =
      acceptAction: @cardDeletionConfirmed
      context: @
    utils.showConfirmationModal('¿Estás seguro de que deseas eliminar esta tarjeta?', options)

  cardDeletionConfirmed: ->
    utils.closeMessageModal()
    utils.showAjaxLoading()
    @model.requestDeleteCard(@cardIdToDelete, @)
        .done(@requestDeleteCardSucceds)
        .always(@requestDeleteCardCompletes)

  requestDeleteCardSucceds: ->
    @model.deleteCard(@cardIdToDelete)
    options =
      icon: 'iconFont-ok'
    utils.showMessageModal('La tarjeta ha sido eliminada correctamente.', options)
    @model.fetch()

  requestDeleteCardCompletes: ->
    utils.hideAjaxLoading()
