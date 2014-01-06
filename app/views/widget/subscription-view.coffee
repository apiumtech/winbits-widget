template = require 'views/templates/widget/subscription'
View = require 'views/base/view'
config = require 'config'
util = require 'lib/util'
vendor = require 'lib/vendor'

module.exports = class SubscriptionView extends View
  autoRender: yes
  container: '#subscription'
  template: template

  render: ->
    super

  initialize: ->
    super
    @delegate 'click', '.editLink', @editSubscription
    @delegate 'click', '.linkBack', @cancelEditing
    @delegate 'click', '#wbi-update-subscription', @saveSubscription
    @delegate 'click', '#cancelEditSubscription', @cancelEditSubscription

    @subscribeEvent 'loggedOut', @resetView

  resetView: ->
    @model.clear()
    @render()

  editSubscription: (e)->
    @$el.find(".miSuscripcion").slideUp()
    @$el.find(".editSuscription").slideDown()

  cancelEditSubscription: (e)->
    e.preventDefault()
    @$el.find(".miSuscripcion").slideDown()
    @$el.find(".editSuscription").slideUp()

  saveSubscription: (e)->
    e.preventDefault()
    console.log "SubscriptionView#saveSubscription"
    sbs = []
    that = @
    @$el.find(".checkbox").each ->
      $this = that.$(this)
      active = $this.attr("checked")
      if active is "checked"
        active = true
      else
        active = false
      id = $this.attr("id")
      console.log id
      unless id is `undefined`
        id = id.slice(0, -4)
        sbs.push
          id: id
          active: active
    format = @$el.find('input[name=newsletterFormat]:checked').val()
    periodicity = @$el.find('input[name=newsletterPeriodicity]:checked').val()

    link = @$el.find('#wbi-update-subscription').prop 'disabled', true
    that=@
    util.ajaxRequest( config.apiUrl + "/affiliation/updateSubscriptions.json",
      type: "PUT"
      contentType: "application/json"
      dataType: "json"
      data: JSON.stringify({subscriptions:sbs, newsletterFormat: format, newsletterPeriodicity: periodicity})
#      context: {$saveLink: link, that: @}

      headers:
        "Accept-Language": "es"
        "WB-Api-Token": util.getCookie(config.apiTokenName)
    )
      success: (data) ->
        console.log ["Subscription updated1", data.response]
        that.publishEvent 'setSubscription', data.response

      error: (xhr, textStatus, errorThrown) ->
        util.showError("Error while updating subscription")

      complete: ->
        console.log "Request Completed!"
        link.prop 'disabled', false

  attach: ()->
    super
    vendor.customCheckbox(@$el.find(".checkbox"))

  cancelEditing: (e) ->
    $editSubscriptionsContainer = @$el.find(".editSuscription")
    $editSubscriptionForm = $editSubscriptionsContainer.find('form')
    $editSubscriptionsContainer.slideUp()
    $editSubscriptionForm.get(0).reset()
    @$el.find(".miSuscripcion").slideDown()
