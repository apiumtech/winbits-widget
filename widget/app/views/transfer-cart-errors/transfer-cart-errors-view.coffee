'use strict'

View = require 'views/base/view'
utils = require 'lib/utils'
cartUtils = require 'lib/cart-utils'
mediator = Winbits.Chaplin.mediator
$ = Winbits.$
_ = Winbits._
env = Winbits.env
CLASS_LOADER_HIDE = 'loader_hide'

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
    utils.closeMessageModal()
    if (mediator.data.get 'virtual-checkout')
      @publishEvent 'checkout-requested'
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
    @itemId = @$('#wbi-id-to-delete').val()
    cartUtils.deleteCartItem(@itemId, context : @).done(@deleteSuccess)

  deleteSuccess:(data) ->
    if ($.isEmptyObject(data.response.cartDetails) )
      if ( mediator.data.get('virtual-checkout'))
        mediator.data.set('virtual-checkout', no)
      unless (@model.hasFailedCartDetails())
        utils.closeMessageModal()
    @$("#item-id-#{@itemId}").remove()
    @$('#wbi-layer-load').addClass('loader-hide')
    @$('#wbi-layer-div').addClass('loader-hide')

