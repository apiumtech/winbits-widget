'use strict'

View = require 'views/base/view'
$ = Winbits.$

module.exports = class CardsView extends View
  container: '#wb-credit-cards'
  template: require './templates/cards'

  initialize: ->
    super
    @listenTo @model, 'change', -> @render()
    @model.fetch()

  attach: ->
    super
    @$('#wbi-cards-carousel').changeBox(
          activo: 'carruselSCC-selected',
          items: '.carruselSCC-div'
       )
    .carouselSwiper({
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
