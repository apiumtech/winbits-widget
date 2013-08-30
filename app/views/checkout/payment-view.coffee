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
    @subscribeEvent "showBitsPayment", @showBitsPayment
    @delegate "click", ".btnPaymentCancel", @linkBack
    @delegate "click", "#spanCheckboxSaveCard", @selectCheckboxOption
    @delegate "click", "#spanCheckboxAsPrincipal", @selectCheckboxOption
    @delegate "click", ".submitCheckoutPaymentNewCard", @payWithCard

  payWithCard: (e) ->
    e.preventDefault()
    that = @
    $form = @$el.find("#checkoutPaymentNewCardFormId")
    $currentTarget = @$(e.currentTarget)
    paymentMethod =  $currentTarget.attr("id").split("-")[1]

    if $form.valid()
      console.log ['valid', $form]
      formData = {paymentInfo : util.serializeForm($form)}
      formData.paymentInfo.currency = config.currency
      formData.paymentMethod = paymentMethod
      formData.order = mediator.post_checkout.order
      formData.vertical = window.verticalId
      formData.shippingAddress = mediator.post_checkout.shippingAddress

      Backbone.$.ajax config.apiUrl + "/orders/payment.json",
        type: "POST"
        contentType: "application/json"
        dataType: "json"
        data: JSON.stringify(formData)

        headers:{ 'Accept-Language': 'es', 'WB-Api-Token': window.token }
        success: (data) ->
          console.log ["data", data]
          payment = data.response.payments[0]
          if payment.status is 'PAID'
            that.publishEvent "setConfirm", data.response
            that.publishEvent "showStep", ".checkoutSummaryContainer", payment
          else
            alert payment.paymentCapture.mensaje

        error: (xhr, textStatus, errorThrown) ->
          console.log xhr
          error = JSON.parse(xhr.responseText)
          #that.renderLoginFormErrors $form, error

        complete: ->
          console.log "Request Completed!"

  selectCheckboxOption: (e)->
    e.preventDefault()
    $currentTarget = @$(e.currentTarget)
    checkboxInput = $currentTarget.parent().find(".checkbox")
    checkboxStatus = checkboxInput.val()
    if checkboxStatus is "true"
      $currentTarget.removeClass "selectCheckbox"
      $currentTarget.addClass "unselectCheckbox"
      checkboxInput.val("false")
    else
      $currentTarget.removeClass "unselectCheckbox"
      $currentTarget.addClass "selectCheckbox"
      checkboxInput.val("true")




  selectMethod: (e)->
    e.preventDefault()
    $currentTarget = @$(e.currentTarget)
    methodName =  $currentTarget.attr("id").split("-")[1]
    selector = "#method-" + methodName
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
        that.publishEvent "setConfirm", data.response
        that.publishEvent "showStep", ".checkoutSummaryContainer", data.response.payments[0]


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
    @$('#method-bits').hide()


  attach: ->
    super

  showBitsPayment: -> 
    @$(".method-payment").hide()
    @$(".checkoutPaymentCreditcard").hide()
    @$('#method-bits').show()
