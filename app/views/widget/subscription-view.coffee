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
    @delegate 'click', '#editBtnSubscription', @editSubscription
    @delegate 'click', '#saveBntSubscription', @saveSubscription
    @delegate 'click', '#cancelEditSubscription', @cancelEditSubscription

  editSubscription: (e)->
    @$el.find(".miSuscripcion").slideUp()
    @$el.find(".editSuscription").slideDown()

  cancelEditSubscription: (e)->
    e.preventDefault()
    @$el.find(".miSuscripcion").slideDown()
    @$el.find(".editSuscription").slideUp()

  cancelEditSubscription: (e)->
    e.preventDefault()
    e.stopPropagation()
    @$el.find(".miSuscripcion").slideDown()
    @$el.find(".editSuscription").slideUp()

  saveSubscription: (e)->
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

    console.log sbs
    that = @
    Backbone.$.ajax config.apiUrl + "/affiliation/updateSubscriptions.json",
      type: "PUT"
      contentType: "application/json"
      dataType: "json"
      data: JSON.stringify({subscriptions:sbs})

      headers:
        "Accept-Language": "es"
        "WB-Api-Token": util.getCookie(config.apiTokenName)

      success: (data) ->
        console.log ["Subscription updated1", data.response]
        console.log subscriptions:data.response
        that.publishEvent 'setSubscription', {subscriptions:data.response}

      error: (xhr, textStatus, errorThrown) ->
        error = JSON.parse(xhr.responseText)
        alert "Error while updating subscription"

      complete: ->
        console.log "Request Completed!"

  attach: ()->
    super
    vendor.customCheckbox(@$el.find(".checkbox"))
