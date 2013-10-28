View = require 'views/base/view'
template = require 'views/templates/checkout/payment-methods'
util = require 'lib/util'
config = require 'config'
mediator = require 'chaplin/mediator'
vendor = require 'lib/vendor'
CardTokenPayment = require 'models/checkout/card-token-payment'
CardTokenPaymentView = require 'views/checkout/card-token-payment-view'

# Site view is a top-level view which is bound to body.
module.exports = class PaymentView extends View
  container: '.checkoutPaymentContainer'
  autoRender: yes
  template: template

  initialize: ->
    super
    @delegate "click" , ".li-method", @selectMethod
    @delegate "click" , ".submitOrder", @submitOrder
    @delegate "click", ".linkBack", @linkBack
    @delegate "click", ".btnPaymentCancel", @linkBack
    @delegate "click", "#spanCheckboxSaveCard", @selectCheckboxOption
    @delegate "click", "#spanCheckboxAsPrincipal", @selectCheckboxOption
    @delegate "click", ".wb-submit-card-payment", @payWithCard
    @delegate 'click', '#wbi-card-token-payment-continue-btn', @onContinueWithCardTokenBtnClick
    @delegate "keyup", ".wb-card-number-input", @showCardType
    @delegate "blur", ".wb-card-number-input", @showCardType

    @subscribeEvent "showBitsPayment", @showBitsPayment
    @subscribeEvent 'cardSelected', @onCardSelected
    @subscribeEvent 'paymentFlowCancelled', @onPaymentFlowCancelled
    @subscribeEvent 'cardTypeChanged', @onCardTypeChanged

    cardTokenPayment = new CardTokenPayment
    @cardTokenPaymentView = new CardTokenPaymentView(model: cardTokenPayment)

  payWithCard: (e) ->
    e.preventDefault()
    that = @
    $currentTarget = @$(e.currentTarget)
    $form = $currentTarget.closest('form.wb-card-form')
    paymentMethod =  $currentTarget.attr("id").split("-")[1]

    if $form.valid()
      formData = paymentInfo : util.serializeForm($form)
      formData.paymentMethod = paymentMethod
      formData.order = mediator.post_checkout.order
      formData.vertical = window.verticalId
      formData.shippingAddress = mediator.post_checkout.shippingAddress
      util.showAjaxIndicator()
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
            util.showError(payment.paymentCapture.mensaje)

        error: (xhr) ->
          util.showAjaxError(xhr.responseText)

        complete: ->
          util.hideAjaxIndicator()

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
    util.showAjaxIndicator()
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
          if paymentMethod is 'paypal.latam'
            paymentCapture = payment.paymentCapture
            params = paymentCapture.params
            window.location = paymentCapture.url + '?cmd=' + params.cmd + '&token=' + params.token
          else
            that.publishEvent "setConfirm", data.response
            that.publishEvent "showStep", ".checkoutSummaryContainer", payment
        else
          util.showError('Error al procesar el pago, por favor intentalo más tarde')


      error: (xhr, textStatus, errorThrown) ->
        util.showAjaxError(xhr.responseText)

      complete: ->
        console.log "Request Completed!"
        util.hideAjaxIndicator()


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
        if $element.attr("name") in ["expirationMonth", "expirationYear"]
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

    @$el.find("#wbi-amex-card-payment-form").validate
      groups:
        cardExpiration: 'expirationMonth expirationYear'
      errorPlacement: ($error, $element) ->
        if $element.attr("name") in ["expirationMonth", "expirationYear"]
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
        cardNumber:
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
        cvv2Number:
          required: true
          digits: true
          minlength: 4
        street:
          required: true
          minlength: 2
        number:
          required: true
        zipCode:
          required: true
          minlength: 4
          digits: true
        phone:
          required: true
          minlength: 7
          digits: true
        city:
          required: true
          minlength: 2
        state:
          required: true
          minlength: 2

  showBitsPayment: -> 
    @$(".method-payment").hide()
    @$(".checkoutPaymentCreditcard").hide()
    @$('#method-bits').show()

  onContinueWithCardTokenBtnClick: (e) ->
    e.preventDefault()
    $cartItem = @$el.find('.wb-card-list-item.creditcardSelected')
    if $cartItem.length > 0
      @$el.children().hide()
      @cardTokenPaymentView.render()
      @cardTokenPaymentView.$el.find('#wbi-card-token-payment-view').show()
    else
      util.showError('Selecciona un medio de pago para continuar')

  onCardSelected: (cardData) ->
    cardInfo = cardData.cardInfo
    mediator.post_checkout.paymentMethod = 'cybersource.token'
    mediator.post_checkout.paymentInfo = subscriptionId: cardInfo.subscriptionId
    @cardTokenPaymentView.model.set cardInfo: cardInfo

  onPaymentFlowCancelled: (e) ->
    @$el.children().hide()
    @$el.find('#wbi-main-payment-view').show()

  showCardType: (e) ->
    $input = Backbone.$(e.currentTarget)
    cardType = util.getCreditCardType($input.val())
    $input.next().removeAttr('class').attr('class', 'wb-card-logo icon ' + cardType + 'CC')

  onCardTypeChanged: (cardType, $form) ->
    if cardType is 'amex'
      $form.find('[name=location], [name=county]').hide().val('').prop('disabled', yes)
    else
      $form.find('[name=location], [name=county]').show().val('').prop('disabled', no)