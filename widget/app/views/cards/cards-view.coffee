'use strict'

View = require 'views/base/view'
$ = Winbits.$

module.exports = class CardsView extends View
  container: '#wb-credit-cards'
  template: require './templates/cards'

  initialize: ->
    super
    @listenTo @model, 'change', -> @render()
    @delegate 'click', '.wbc-card', -> @onCardClick.apply(@, arguments)
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
    if not $card.children('.carruselSCC-selected').length
      id = $card.data('id')
      @model.requestSetDefaultCard(id)
