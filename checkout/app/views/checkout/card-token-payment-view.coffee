View = require 'views/base/view'
template = require 'views/templates/checkout/card-token-payment'
util = require 'lib/util'
config = require 'config'
mediator = require 'chaplin/mediator'
vendor = require 'lib/vendor'

# Site view is a top-level view which is bound to body.
module.exports = class CardTokenPaymentView extends View
  container: '.checkoutPaymentContainer'
  autoRender: no
  template: template

  initialize: ->
    super
    @delegate "click" , "#wbi-cancel-card-token-payment-btn", @onCancelCardTokenPaymentBtnClick
    @delegate 'submit', 'form#wbi-card-token-payment-form', @onCardTokenPaymentFormSubmitted

  attach: ->
    super
    Winbits.$('.select').customSelect()
    @$el.find('form#wbi-card-token-payment-form').validate
      rules:
        msi:
          required: true
        cvNumber:
          required: true
          digits: true
        totalMsi:
          required: true
          minlength: 1
          digits: true

  onCancelCardTokenPaymentBtnClick: (e) ->
    e.preventDefault()
    
    Winbits.$(".chk-step > div:visible div:visible.wbiPaymentMethod").hide()
    Winbits.$("#wbi-cards-list-holder").show()
    Winbits.$("#wbi-main-payment-view").show()
    util.renderSliderOnPayment(100, true)
    @publishEvent 'paymentFlowCancelled'


  checkRegularPayment:(totalMsi)->
    console.log ["total msi ", totalMsi]
    parseInt(totalMsi) is 1


  onCardTokenPaymentFormSubmitted: (e) ->
    e.preventDefault()
    #
    $ = Winbits.$
    $form = $(e.currentTarget)
    if $form.valid()
      paymentData = mediator.post_checkout
      paymentData.vertical = Winbits.checkoutConfig.verticalId
      formData = util.serializeForm($form)

      if new RegExp("cybersource\..+").test(paymentData.paymentMethod)
        formData.deviceFingerPrint = Winbits.checkoutConfig.orderId

      if formData.totalMsi and paymentData.paymentMethod isnt 'amex.cc'
        if not @checkRegularPayment(formData.totalMsi)
          paymentData.paymentMethod = 'cybersource.token.msi.' + formData.totalMsi
          formData.totalMsi = parseInt formData.totalMsi, 10
        else
          paymentData.paymentMethod = 'cybersource.token'

      
      if paymentData.paymentMethod is 'amex.cc'
       cardData = @model.get("cardInfo").cardData
       cardAddress = @model.get("cardInfo").cardAddress
       formData.cardNumber = cardData.unmasked
       formData.city = cardAddress.city
       formData.county = ''
       formData.firstName = cardData.firstName
       formData.lastName = cardData.lastName
       formData.number = cardAddress.number
       formData.phone = cardData.phoneNumber
       formData.state = cardAddress.state
       formData.street = cardAddress.street1
       formData.zipCode = cardAddress.postalCode
       formData.cvv2Number = formData.cvNumber
       formData.location = ''
       formData.expirationYear = cardData.expirationYear
       formData.expirationMonth = cardData.expirationMonth

       delete formData['cvNumber']
       delete paymentData.paymentInfo['subscriptionId']

       if formData.totalMsi and not @checkRegularPayment(formData.totalMsi)
         paymentData.paymentMethod = 'amex.msi.' + formData.totalMsi
         formData.numberOfPayments = parseInt formData.totalMsi, 10
         delete formData['totalMsi']
        else
         delete formData['totalMsi']


      $.extend paymentData.paymentInfo, formData
      util.showAjaxIndicator('Procesando tu pago...')
      that=@
      util.ajaxRequest( config.apiUrl + "/orders/payment.json",
        type: "POST"
        contentType: "application/json"
        dataType: "json"
        data: JSON.stringify(paymentData)
        headers:{ 'Accept-Language': 'es', 'WB-Api-Token': util.retrieveKey(config.apiTokenName) }
        success: (data) ->
          console.log ["data", data]
          # Stop timer
          that.publishEvent 'StopIntervalTimer'
          payment = data.response.payments[0]
          bitsPayment = data.response.payments[1]
          if payment.status isnt 'FAILED' and payment.status isnt 'ERROR'
            that.$el.hide()
            that.publishEvent "setConfirm", data.response
            that.publishEvent "showStep", ".checkoutSummaryContainer", payment, bitsPayment
            #ocultamos el mensaje de bits
            util.renderSliderOnPayment 100, true
          else
            util.showError(payment.paymentCapture.mensaje || payment.paymentCapture.message)
        error: () ->
          util.showError('Por favor verifica tus datos o comunícate con nosotros para ayudarte a concretar la compra al 4160-0550')
        complete: ->
          util.hideAjaxIndicator()
      )
