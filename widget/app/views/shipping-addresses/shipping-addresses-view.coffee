'use strict'

View = require 'views/base/view'
utils = require 'lib/utils'
AddNewShippingAddress = require './add-new-shipping-address-view'
mediator = Winbits.Chaplin.mediator
$ = Winbits.$
env = Winbits.env

module.exports = class ShippingAddressesView extends View
  container: '#wb-shipping-addresses'
  template: require './templates/shipping-addresses'

  initialize: ->
    super
    @listenTo @model,  'change', -> @render()
    @model.fetch()
    @delegate 'click', '#wbi-add-new-shipping-address' , @showAddNewShipping
    @delegate 'click', '#wbi-add-shipping-address-cancel', @cancelAddNewShipping
    @delegate 'click', '#wbi-shipping-address-done-btn', @cancelAddNewShipping
    @delegate 'click', '#wbi-add-shipping-address-submit-btn', @doSaveShippingAddress

  render: ->
    super
    newShippingAddressContainer = @$el.find('#wbi-shipping-new-address-container').get(0)
    @subview 'add-new-shipping-addresses', new AddNewShippingAddress, container: newShippingAddressContainer, model: @model

  attach: ->
    super
    #script to implement carrusel
    @$('.block-carrusel').changeBox(
          activo: 'carruselSCC-selected',
          items: '.carruselSCC-div'
       )
    .carouselSwiper({
          optionsSwiper:{
            slideClass: 'block-slide',
            wrapperClass: 'block-wrapper',
            grabCursor: true,
            useCSS3Transforms: false,
            cssWidthAndHeight: false,
            slidesPerView: 4
            },
          arrowLeft: '.iconFont-left',
          arrowRight: '.iconFont-right',
          slidesNum: 4,
          slideCSS: '.block-slide',
          initialSlide: '.carruselSCC-selected'
    })

  showAddNewShipping:(e) ->
    e.preventDefault()
    @$('#wbi-shipping-addresses-view').slideUp()
    @$('#wbi-shipping-new-address-container').slideDown()

  cancelAddNewShipping: (e) ->
    e.preventDefault()
    @$('#wbi-shipping-addresses-view').slideDown()
    @$('#wbi-shipping-new-address-container').slideUp()
    $form = @$('#wbi-shipping-new-address-form')
    utils.justResetForm($form)
    if not @$('.thanks-div').is(':hidden')
      @$('#wbi-shipping-thanks-div').slideUp()
      @model.fetch()

  doSaveShippingAddress: ->
    $form =  @$el.find("#wbi-shipping-new-address-form")
    @$('.errorDiv p').hide()
    data = utils.serializeForm $form
    if($form.valid())
       @$('#wbi-shipping-thanks-div').show()
       @model.requestSaveNewShippingAddress(data, context: @)
        .done(@successSaveNewShippingAddress)
        .fail(@errorSaveNewShippingAddress)

  successSaveNewShippingAddress:()->
    @$('#wbi-shipping-address-process').hide()
    @$('#wbi-shipping-address-done').show()


  errorSaveNewShippingAddress:(xhr)->
    @$('#wbi-shipping-thanks-div').hide()
    error = utils.safeParse(xhr.responseText)
    message = if error then error.meta.message else textStatus
    @$('.errorDiv p').text(message).parent().css('display':'block')

