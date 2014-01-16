template = require 'views/templates/widget/failed-cart-items'
View = require 'views/base/view'
FailedCartItems = require "models/failed-cart-items"
config = require 'config'
util = require 'lib/util'
mediator = require 'chaplin/mediator'

module.exports = class FailedCartItemsView extends View
  autoRender: yes
  container: '#wbi-failed-cart-items-modal-body'
  template: template

  render: ->
    super

  initialize: ->
    super
    @model = new FailedCartItems()
    that = @
    @model.on "change", -> that.render()
    @subscribeEvent 'cartItemsIssues', @showFailedCartItems

    @delegate 'click', '.wb-continue-btn', @closeModal
    @delegate 'click', '.wb-remove-cart-item-btn', @removeCartItem

  attach: ->
    super
    @modal = @$el.closest('.modal').modal(show: false)

  showFailedCartItems: () ->
    @modal.modal('show')

  closeModal: ->
    @modal.modal('hide')
    @publishEvent 'doCheckout' if mediator.flags.autoCheckout

  removeCartItem: (e) ->
    e.preventDefault()
    $cartItemRow = Winbits.$(e.currentTarget).closest('.wb-cart-item-row')
    @publishEvent 'cartItemRemoved', $cartItemRow.data('id'), () ->
      $cartItemRow.remove()