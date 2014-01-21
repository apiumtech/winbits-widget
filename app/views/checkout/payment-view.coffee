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
    @delegate "textchange", ".wb-card-number-input", @showCardType
    @delegate "blur", ".wb-card-number-input", @showCardType
    @delegate 'change', '.wb-card-save-checkbox', @onCardSaveChange

    @subscribeEvent "showBitsPayment", @showBitsPayment
    @subscribeEvent 'paymentFlowCancelled', @onPaymentFlowCancelled

    cardTokenPayment = new CardTokenPayment
    @cardTokenPaymentView = new CardTokenPaymentView(model: cardTokenPayment)

  payWithCard: (e) ->
    e.preventDefault()
    that = @
    $currentTarget = @$(e.currentTarget)
    $form = $currentTarget.closest('form.wb-card-form')
    paymentMethod =  $currentTarget.attr("id").split("-")[1]

    if $form.valid()
      formData = util.serializeForm($form)
      formData.cardSave = formData.hasOwnProperty('cardSave')
      formData.cardPrincipal = formData.hasOwnProperty('cardPrincipal')
      postData = paymentInfo : formData
      postData.paymentMethod = paymentMethod
      postData.order = mediator.post_checkout.order
      postData.vertical = Winbits.checkoutConfig.verticalId
      postData.shippingAddress = mediator.post_checkout.shippingAddress
      util.showAjaxIndicator('Procesando tu pago...')

      util.ajaxRequest( config.apiUrl + "/orders/payment.json",
        type: "POST"
        contentType: "application/json"
        dataType: "json"
        data: JSON.stringify(postData)

        headers:{ 'Accept-Language': 'es', 'WB-Api-Token': util.retrieveKey(config.apiTokenName) }
        success: (data) ->
          console.log ["data", data]
          payment = data.response.payments[0]
          bitsPayment = data.response.payments[1]
          if payment.status isnt 'FAILED' and payment.status isnt 'ERROR'
            that.publishEvent "setConfirm", data.response
            that.publishEvent "showStep", ".checkoutSummaryContainer", payment, bitsPayment
          else
            cardErrorMessage = payment.paymentCapture.mensaje or payment.paymentCapture.message
            util.showError(cardErrorMessage or 'Tu tarjeta fue rechazada por el banco emisor. Por favor revisa la información y vuelve a intentarlo')
        error: () ->
          util.showError('El servicio de pagos no se encuentra disponible. Por favor intántalo más tarde')
        complete: ->
          util.hideAjaxIndicator()
      )

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
    console.log ('Selected method ' + $currentTarget.attr("id").split("-")[1])
    methodName =  $currentTarget.attr("id").split("-")[1]
    selector = "#method-" + methodName
    @$(selector).show()
    @$(".checkoutPaymentCreditcard").hide()

  submitOrder: (e)->
    e.preventDefault()
    console.log "submit order"
    @publishEvent 'StopIntervalTimer'
    that = @
    $currentTarget = @$(e.currentTarget)
    paymentMethod =  $currentTarget.attr("id").split("-")[1]
    mediator.post_checkout.paymentMethod = paymentMethod

    formData = mediator.post_checkout
    formData.vertical = Winbits.checkoutConfig.verticalId
    util.showAjaxIndicator('Procesando tu pago...')

    util.ajaxRequest( config.apiUrl + "/orders/payment.json",
      type: "POST"
      contentType: "application/json"
      dataType: "json"
      data: JSON.stringify(formData)

      headers:{ 'Accept-Language': 'es', 'WB-Api-Token': util.retrieveKey(config.apiTokenName) }
      success: (data) ->
        console.log ["data", data]
        payment = data.response.payments[0]
        bitsPayment = data.response.payments[1]
        if payment.status isnt 'FAILED' and payment.status isnt 'ERROR'
          if payment.identifier is 'paypal.latam'
            util.showAjaxIndicator('Redireccionando a PayPal...')
            paymentCapture = payment.paymentCapture
            params = paymentCapture.params
            window.location = paymentCapture.url + '?cmd=' + params.cmd + '&token=' + params.token
          else
            util.hideAjaxIndicator()
            that.publishEvent "setConfirm", data.response
            that.publishEvent "showStep", ".checkoutSummaryContainer", payment, bitsPayment
        else
          util.showError('Error al procesar el pago, por favor intentalo más tarde')
          util.hideAjaxIndicator()
      error: () ->
        util.showError('El servicio de pagos no se encuentra disponible. Por favor intántalo más tarde')
        util.hideAjaxIndicator()
    )

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
        if $element.attr("name") in ["expirationMonth", "expirationYear", 'accountNumber']
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
          minlength: 16
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
        phoneNumber:
          required: true
          minlength: 10
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
          minlength: 10
          digits: true
        city:
          required: true
          minlength: 2
        location:
          required: true
          minlength: 2
        county:
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
    $cartItem = @$el.find('.wb-card-list-item.creditcardSelected:visible')

    util.renderSliderOnPayment(100, false)
    if $cartItem.length > 0
      @$el.children().hide()
      cardData = @cardsView.getCardDataAt $cartItem.index()
      console.log ['CARD DATA', cardData]
      @setupPaymentWithToken cardData
    else
      util.showError('Selecciona un medio de pago para continuar')

  setupPaymentWithToken: (cardData) ->
    cardInfo = cardData.cardInfo
    mediator.post_checkout.paymentMethod = 'cybersource.token'
    mediator.post_checkout.paymentInfo = subscriptionId: cardInfo.subscriptionId

    if cardInfo.cardData.cardType is "American Express"
      cardInfo.maxSecurityNumber = 4
      cardInfo.securityNumberPlaceholder = "\#\#\#\#"
    else
      cardInfo.maxSecurityNumber = 3
      cardInfo.securityNumberPlaceholder = "\#\#\#"

    @cardTokenPaymentView.model.set cardInfo: cardInfo
    @cardTokenPaymentView.render()
    @cardTokenPaymentView.$el.find('#wbi-card-token-payment-view').show()

  onPaymentFlowCancelled: (e) ->
    @$el.children().hide()
    @$el.find('#wbi-main-payment-view').show()

  showCardType: (e) ->
    $input = Winbits.$(e.currentTarget)
    cardNumber = $input.val() or ''
    if cardNumber.length > 14
      cardType = util.getCreditCardType(cardNumber)
      cardType = 'unknown' if cardType is 'amex'
      $input.next().removeAttr('class').attr('class', 'wb-card-logo icon ' + cardType + 'CC')

  onCardSaveChange: (e) ->
    $checkbox = Winbits.$(e.currentTarget)
    checked = $checkbox.is ':checked'
    $checkbox.closest('form').find('.wb-card-principal-checkbox').prop('disabled', !checked).prop('checked', false)
