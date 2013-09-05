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
    $form = @$el.find("#wbi-credit-card-payment-form")
    $currentTarget = @$(e.currentTarget)
    paymentMethod =  $currentTarget.attr("id").split("-")[1]

    if $form.valid()
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
          if payment.status isnt 'FAILED' and payment.status isnt 'ERROR'
            that.publishEvent "setConfirm", data.response
            that.publishEvent "showStep", ".checkoutSummaryContainer", payment
          else
            alert payment.paymentCapture.mensaje

        error: (xhr, textStatus, errorThrown) ->
          console.log xhr
          error = JSON.parse(xhr.responseText)
          alert error.meta.message

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
        payment = data.response.payments[0]
        if payment.status isnt 'FAILED' and payment.status isnt 'ERROR'
          that.publishEvent "setConfirm", data.response
          that.publishEvent "showStep", ".checkoutSummaryContainer", payment
        else
          alert 'Error al procesar el pago, por favor intentalo más tarde'


      error: (xhr, textStatus, errorThrown) ->
        console.log xhr
        error = JSON.parse(xhr.responseText)
        alert error.meta.message

      complete: ->
        console.log "Request Completed!"


  linkBack: (e) ->
    e.preventDefault()
    @$(".checkoutPaymentCreditcard").show()
    @$(".method-payment").hide()
    @$('#method-bits').hide()


  attach: ->
    super
    @$el.find("#wbi-credit-card-payment-form").validate
      groups:
        cardExpiration: 'expirationMonth expirationYear'
      errorPlacement: ($error, $element) ->
        if $element.attr("name") is "expirationMonth" or $element.attr("name") is "expirationYear"
          $error.appendTo $element.parent()
        else
          $error.insertAfter $element
      rules:
        firstName:
          required: true
          minlength: 2
        lastName:
          required: true
          minlength: 2
        accountNumber:
          required: true
          creditcard: true
        expirationMonth:
          required: true
          minlength: 2
          digits: true
          range: [1, 12]
        expirationYear:
          required: true
          minlength: 2
          digits: true
        cvNumber:
          required: true
          digits: true
          minlength: 3
        street1:
          required: true
          minlength: 2
        number:
          required: true
        postalCode:
          required: true
          minlength: 5
          digits: true
        phone:
          required: true
          minlength: 7
          digits: true
        state:
          required: true
          minlength: 2
        colony:
          required: true
          minlength: 2
        municipality:
          required: true
          minlength: 2
        city:
          required: true
          minlength: 2

  showBitsPayment: -> 
    @$(".method-payment").hide()
    @$(".checkoutPaymentCreditcard").hide()
    @$('#method-bits').show()
