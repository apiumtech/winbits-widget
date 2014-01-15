template = require 'views/templates/widget/failed-cart-items'
View = require 'views/base/view'
FailedCartItems = require "models/failed-cart-items"
config = require 'config'
util = require 'lib/util'

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
    @subscribeEvent 'cartItemsFailed', @showFailedCartItems

    @delegate 'click', '.wb-continue-btn', @closeModal

  attach: ->
    super
    @modal = @$el.closest('.modal').modal(show: false)

  showFailedCartItems: () ->
    @modal.modal('show')

  closeModal: ->
    @modal.modal('hide')