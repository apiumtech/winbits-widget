'use strict'

View = require 'views/base/view'
$ = Winbits.$
DEFAULT_CARD_CLASS = 'carruselSCC-selected'

module.exports = class CardsView extends View
  container: '#wb-credit-cards'
  template: require './templates/cards'

  initialize: ->
    super
    @listenTo @model, 'change', -> @render()
    @clickOnCardHandler = @delegate 'click', '.wbc-card', -> @onCardClick.apply(@, arguments)
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
    $card = $(e.currentTarget)
    if not $card.is(".#{DEFAULT_CARD_CLASS}")
      id = $card.data('id')
      @cardCandidate = $card
      @turnCardsClickEvent('off')
      @model.requestSetDefaultCard(id, @)
          .done(@setDefaultCardSucceds)
          .always(-> @turnCardsClickEvent('on'))

  setDefaultCardSucceds: ->
    @getDefaultCard().removeClass(DEFAULT_CARD_CLASS)
    @cardCandidate.addClass(DEFAULT_CARD_CLASS)

  getDefaultCard: ->
    @$(".wbc-card.#{DEFAULT_CARD_CLASS}")

  turnCardsClickEvent: (state) ->
    @$el[state]('click', '.wbc-card', @clickOnCardHandler)
