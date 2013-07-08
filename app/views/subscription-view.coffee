template = require 'views/templates/subscription'
View = require 'views/base/view'

module.exports = class SubscriptionView extends View
  autoRender: yes
  container: '#subscription'
  template: template

  render: ->
    console.log "(;{)"
    super

  initialize: ->
    super
    @delegate 'click', '#editBtnSubscription', @editSubscription

  editSubscription: (e)->
    console.log "---->"
    @$el.find(".miSuscripcion").slideUp()
    @$el.find(".editSuscription").slideDown()

