'use strict'

View = require 'views/base/view'
utils = require 'lib/utils'
cartUtils = require 'lib/cart-utils'
mediator = Winbits.Chaplin.mediator
$ = Winbits.$
_ = Winbits._
env = Winbits.env

module.exports = class LoginView extends View
  container: '#wbi-winbits-modals'
  id: 'wbi-login-modal'
  template: require './templates/transfer-cart-errors'

  initialize: ->
    super
    @delegate 'click', '#wbi-continue-transfer-btn', @doCloseModal
    @delegate 'click', '.wbc-delete-cart-item-btn', @doDeleteItem
    @delegate 'click', '#wbi-cancel-delete-btn', @doCancelDeleteItem
    @delegate 'click', '#wbi-confirm-delete-btn', @doConfirmDeleteItem

  attach: ->
    super
    @showAsModal()
    @$('.productTable.scrollPanel').scrollpane({ parent: '.dataTable'});

  showAsModal: ->
    $('<a>').wbfancybox(href: '#' + @id, onClosed: (-> utils.redirectTo(controller: 'home', action: 'index', params: 'xxxxxx')), height:550).click()

  doCloseModal: (e)->
    e.preventDefault()
    if (mediator.data.get 'virtual-checkout')
      @publishEvent 'checkout-requested'
    else
      utils.closeMessageModal()
    mediator.data.set('virtual-checkout', no)

  doDeleteItem: (e)->
    e.preventDefault()
    $itemId = $(e.currentTarget).data('id')
    @$('#wbi-layer-div').removeClass('loader-hide')
    @$('#wbi-layer-confirm').removeClass('loader-hide')
    @$('#wbi-id-to-delete').val($itemId)

  doCancelDeleteItem: (e)->
    e.preventDefault()
    @$('#wbi-layer-div').addClass('loader-hide')
    @$('#wbi-layer-confirm').addClass('loader-hide')

  doConfirmDeleteItem: (e)->
    e.preventDefault()
    @$('#wbi-layer-confirm').addClass('loader-hide')
    @$('#wbi-layer-load').removeClass('loader-hide')
    $cartDetails = @model.get 'cartDetails'
    cartDetails =[]
    $itemId = @$('#wbi-id-to-delete').val()
    cartDetails.push(cartDetail) for cartDetail in $cartDetails when cartDetail.skuProfile.id is not $itemId
#    @render(@$('div.dataTable'))
    @model.set 'cartDetails', cartDetails
    @$("#item-id-#{$itemId}").remove()
#    cartUtils.deleteToCart(id).done(@)
