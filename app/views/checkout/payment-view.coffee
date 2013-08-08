View = require 'views/base/view'
template = require 'views/templates/checkout/payment-methods'
util = require 'lib/util'
config = require 'config'
mediator = require 'chaplin/mediator'

# Site view is a top-level view which is bound to body.
module.exports = class PaymentView extends View
  container: '.checkoutPaymentContainer'
  autoRender: yes
  #regions:
  #'#header-container': 'header'
  #'#page-container': 'main'
  template: template

  initialize: ->
    super
    @delegate "click" , ".li-method", @selectMethod
    @delegate "click" , ".submitOrder", @submitOrder
    @delegate "click", ".linkBack", @linkBack
    @delegate "click", ".btnPaymentCancel", @linkBack

  selectMethod: (e)->
    e.preventDefault()
    $currentTarget = @$(e.currentTarget)
    methodName =  $currentTarget.attr("id").split("-")[1]
    selector = "#method-" + methodName
    console.log ["Selector", selector]
    @$(selector).show()
    @$(".checkoutPaymentCreditcard").hide()

  submitOrder: (e)->
    e.preventDefault()
    console.log "submit order"
    that = @
    $currentTarget = @$(e.currentTarget)
    paymentMethod =  $currentTarget.attr("id").split("-")[1]
    mediator.post_checkout.paymentMethod = paymentMethod

    formData = mediator.post_checkout
    formData.vertical = window.verticalId

    Backbone.$.ajax config.apiUrl + "/orders/payment.json",
      type: "POST"
      contentType: "application/json"
      dataType: "json"
      data: JSON.stringify(formData)

      headers:{ 'Accept-Language': 'es', 'WB-Api-Token': window.token }
      success: (data) ->
        console.log ["data", data]
        that.publishEvent "setConfirm", data.response.payments[0]
        that.publishEvent "showStep", ".checkoutSummaryContainer"


      error: (xhr, textStatus, errorThrown) ->
        console.log xhr
        error = JSON.parse(xhr.responseText)
        that.renderLoginFormErrors $form, error

      complete: ->
        console.log "Request Completed!"


  linkBack: (e) ->
    e.preventDefault()
    @$(".checkoutPaymentCreditcard").show()
    @$(".method-payment").hide()


  attach: ->
    super
