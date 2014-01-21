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
    vendor.customSelect(@$el.find('.select'))
    @$el.find('form#wbi-card-token-payment-form').validate
      rules:
        msi:
          required: true
        cvNumber:
          required: true
          digits: true
          minlength: 3

  onCancelCardTokenPaymentBtnClick: (e) ->
    e.preventDefault()
    @$el.children().hide()
    util.renderSliderOnPayment(100, true)
    @publishEvent 'paymentFlowCancelled'

  onCardTokenPaymentFormSubmitted: (e) ->
    e.preventDefault()
    # Stop timer
    @publishEvent 'StopIntervalTimer'
    #
    $ = Winbits.$
    $form = $(e.currentTarget)
    if $form.valid()
      paymentData = mediator.post_checkout
      paymentData.vertical = Winbits.checkoutConfig.verticalId
      formData = util.serializeForm($form)
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
          payment = data.response.payments[0]
          bitsPayment = data.response.payments[1]
          if payment.status isnt 'FAILED' and payment.status isnt 'ERROR'
            that.$el.hide()
            that.publishEvent "setConfirm", data.response
            that.publishEvent "showStep", ".checkoutSummaryContainer", payment, bitsPayment
          else
            util.showError(payment.paymentCapture.mensaje || payment.paymentCapture.message)
        error: () ->
          util.showError('El servicio de pagos no se encuentra disponible. Por favor intántalo más tarde')
        complete: ->
          util.hideAjaxIndicator()
      )
