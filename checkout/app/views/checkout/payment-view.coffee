View = require 'views/base/view'
template = require 'views/templates/checkout/payment-methods'
util = require 'lib/util'
validators = require 'lib/validators'
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
    @delegate "click", ".li-method", @selectMethod
    @delegate "click", ".submitOrder", @submitOrder
    @delegate "click", ".linkBack", @linkBack
    @delegate "click", ".btnPaymentCancel", @linkBack
    @delegate "click", "#spanCheckboxSaveCard", @selectCheckboxOption
    @delegate "click", "#spanCheckboxAsPrincipal", @selectCheckboxOption
    @delegate "click", ".wb-submit-card-payment", @payWithCard
    @delegate 'click', '#wbi-card-token-payment-continue-btn', @onContinueWithCardTokenBtnClick
    @delegate "textchange", ".wb-card-number-input", @showCardType
    @delegate "blur", ".wb-card-number-input", @showCardType
    @delegate 'change', '.wb-card-save-checkbox', @onCardSaveChange
    @delegate 'focusout', '#method-amex_msi .wb-card-number-input', @checkForValidMsiMethod
    @delegate 'focusout', '#method-cybersource_msi .wb-card-number-input', @checkForValidMsiMethod

    @subscribeEvent "showBitsPayment", @showBitsPayment
    @subscribeEvent 'paymentFlowCancelled', @onPaymentFlowCancelled

    cardTokenPayment = new CardTokenPayment
    @cardTokenPaymentView = new CardTokenPaymentView(model: cardTokenPayment)

  checkForValidMsiMethod: (e) ->
      e.preventDefault()
      console.log ["Alert checkForValidMsiMethod"]
      Winbits.$(e.target).valid() 

  payWithCard: (e) ->
    e.preventDefault()
    that = @
    $currentTarget = @$(e.currentTarget)
    $form = $currentTarget.closest('form.wb-card-form')
    paymentMethod =  $currentTarget.attr("id").split("-")[1]
    if paymentMethod is 'amex_msi'
      identifier = 'amex.msi'
    else
      identifier = method.identifier for method in @model.attributes.methods when method.id is  parseInt(paymentMethod, 10)
    console.log 'identifier', identifier
    console.log 'paymentMethod', paymentMethod

    if $form.valid()
      formData = util.serializeForm($form)
      formData.cardSave = formData.hasOwnProperty('cardSave')
      formData.cardPrincipal = formData.hasOwnProperty('cardPrincipal')
      #hack for MSI
      if formData.numberOfPayments
        formData.numberOfPayments = parseInt formData.numberOfPayments, 10
        paymentMethod = "amex.msi." + formData.numberOfPayments
        paymentMethod = method.id for method in @model.attributes.methods when method.identifier is paymentMethod
      if formData.totalMsi
        formData.totalMsi = parseInt formData.totalMsi, 10
        paymentMethod = "cybersource.msi." + formData.totalMsi
        paymentMethod = method.id for method in @model.attributes.methods when method.identifier is paymentMethod
        
      if !new RegExp("amex\..+").test(identifier)
        formData.deviceFingerPrint = Winbits.checkoutConfig.orderId

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

    #hack for MSI
    if formData?.numberOfPayments
      formData.numberOfPayments = parseInt formData.numberOfPayments, 10
      paymentMethod = "amex.msi." + formData.numberOfPayments
      paymentMethod = method.id for method in @model.attributes.methods when method.identifier is paymentMethod
    if formData?.totalMsi
      formData.totalMsi = parseInt formData.totalMsi, 10
      paymentMethod = "cybersource.msi." + formData.totalMsi
      paymentMethod = method.id for method in @model.attributes.methods when method.identifier is paymentMethod
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
    @$el.find("#wbi-credit-card-payment-form").validate().resetForm()
    @$el.find("#wbi-credit-card-payment-form-msi").validate().resetForm()
    @$el.find("#wbi-amex-card-payment-form").validate().resetForm()
    @$el.find("#method-amex_msi form").validate().resetForm()
    @$(".checkoutPaymentCreditcard").show()
    @$(".method-payment").hide()
    @$('#method-bits').hide()


  attach: ->
    super
    vendor.customSelect(@$el.find('.select'))
    Winbits.$("#method-cybersource_msi .selectContent").hide()
    Winbits.$("#method-cybersource_msi .selectTrigger").hide()
    Winbits.$("#method-cybersource_msi .selectPreMessage").show()

    Winbits.$("#method-amex_msi .selectContent").hide()
    Winbits.$("#method-amex_msi .selectTrigger").hide()
    Winbits.$("#method-amex_msi .selectPreMessage").show()
    
    @$el.find("#wbi-credit-card-payment-form").validate
      groups:
        cardExpiration: 'expirationMonth expirationYear'
      errorPlacement: ($error, $element) ->
        if $element.attr("name") in ["expirationMonth", "expirationYear", 'accountNumber']
          $error.appendTo $element.parent()
        else
          $error.insertAfter $element
      rules:
        validators.wbiCreditCardPayment

    creditCardValidator = Winbits.$.extend {},  validators.wbiCreditCardPayment, validators.wbiCreditCardPaymentMsi
    @$el.find("#wbi-credit-card-payment-form-msi").validate
      groups:
        cardExpiration: 'expirationMonth expirationYear'
      errorPlacement: ($error, $element) ->
        if $element.attr("name") in ["expirationMonth", "expirationYear", 'accountNumber']
          $error.appendTo $element.parent()
        else
          $error.insertAfter $element
      rules:
        creditCardValidator
      messages:
        accountNumber:
          remote:
            "La tarjeta no cuenta con promoción a MSI"        

    @$el.find("#wbi-amex-card-payment-form").validate
      groups:
        cardExpiration: 'expirationMonth expirationYear'
      errorPlacement: ($error, $element) ->
        if $element.attr("name") in ["expirationMonth", "expirationYear"]
          $error.appendTo $element.parent()
        else
          $error.insertAfter $element
      rules:
        validators.wbiAmexCardPayment

    amexCardValidator = Winbits.$.extend {},  validators.wbiAmexCardPayment, validators.wbiAmexCardPaymentMsi
    @$el.find("#method-amex_msi form").validate
      groups:
        cardExpiration: 'expirationMonth expirationYear'
      errorPlacement: ($error, $element) ->
        if $element.attr("name") in ["expirationMonth", "expirationYear", 'accountNumber']
          $error.appendTo $element.parent()
        else
          $error.insertAfter $element
      rules:
        amexCardValidator
      messages:
        cardNumber:
          remote:
            "La tarjeta no cuenta con promoción a MSI"        

  showBitsPayment: -> 
    @$(".method-payment").hide()
    @$(".checkoutPaymentCreditcard").hide()
    @$('#method-bits').show()

  onContinueWithCardTokenBtnClick: (e) ->
    e.preventDefault()
    $cartItem = @$el.find('.wb-card-list-item.creditcardSelected:visible:not(.creditcardNotEligible)')

    if $cartItem.length > 0
      @$el.children().hide()
      cardData = @cardsView.getCardDataAt $cartItem.index()
      @setupPaymentWithToken cardData
      util.renderSliderOnPayment(100, false)
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
    @cardTokenPaymentView.model.set methods: @cardsView.model.attributes.methods
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
