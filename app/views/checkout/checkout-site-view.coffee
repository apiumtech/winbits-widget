View = require 'views/base/view'
template = require 'views/templates/checkout/checkout-site'
util = require 'lib/util'
config = require 'config'

# Site view is a top-level view which is bound to body.
module.exports = class CheckoutSiteView extends View
  container: 'body'
  autoRender: true
  #regions:
  #'#header-container': 'header'
  #'#page-container': 'main'
  template: template

  initialize: ->
    super
    @subscribeEvent "showStep", @showStep
    @subscribeEvent "hideAddress", @hideAddress
    @delegate "click","#showAddress", @showAddress
    @delegate 'click', '.close-modal', @closeModal
    @delegate 'click', 'i.close-icon', @closeModal
    @delegate 'click', '#wbi-winbits-logo', @onWinbitsLogoClick

#    Backbone.$.validator.addMethod "cyberSourceCard", (value, element) ->
#      @optional(element) or util.getCreditCardType(value) in ['visa', 'mastercard']
#    , "Introduce una tarjeta VISA ó MasterCard"

  closeModal: (event) ->
    event?.preventDefault()
    event?.stopPropagation()
    @$('.modal').modal 'hide'

  showAddress: (e)->
    e.preventDefault()
    @$("#showAddress").hide()
    @$(".choosen-address").hide()
    @showStep(".shippingAddresses")

  showStep: (selector, payment, bitsPayment)->
    if selector is ".checkoutPaymentContainer"
      #display edit link
      @$("#showAddress").show()
    if payment
      @publishEvent 'orderProcessed', payment: payment
      @$("#showAddress").hide()
      @$("div.slider").hide()
      @$("span.legendCarrito").hide()
      @$('#wb-checkout-timer').parent().hide()
      if bitsPayment
        $bitsAmount = @$("span.bits-payment-data").show().filter('.bits-amount')
        $bitsAmount.html($bitsAmount.html() + '-' + bitsPayment.amount)
    else
      @$(".chk-step").hide()
    @$(selector).show()

  hideAddress: ()->
    @$(".checkoutShipping").hide()
    @$("#circuledNumber2").html("1")
    @$("#circuledNumber3").html("2")

  attach: () ->
    super
    @startCounter()
    @$el.find('#wbi-ajax-modal').modal({backdrop: 'static', keyboard: false, show: false})

  startCounter: () ->
    that = @
    $timer = @$el.find('#wb-checkout-timer')
    console.log(["The timer", $timer])
    $interval = setInterval () ->
      that.updateCheckoutTimer($timer, $interval)
    , 1000

  updateCheckoutTimer: ($timer, $interval) ->
    minutes = $timer.data('minutes')
    minutes = if minutes? then minutes else 30
    seconds = $timer.data('seconds') || 0
    seconds = seconds - 1
    if minutes is 0 and seconds < 0
      console.log('expire order')
      clearInterval $interval
      util.showError("Tu orden ha expirado")
      setInterval () ->
        util.redirectToVertical(window.verticalUrl)
      , 3000
    else
      if seconds < 0
        seconds = 59
        minutes = minutes - 1
      $timer.data('minutes', minutes)
      $timer.data('seconds', seconds)
      $timer.text @formatTime(minutes) + ':' + @formatTime(seconds)

  formatTime: (time) ->
    ('0' + time).slice(-2)

  onWinbitsLogoClick: (e) ->
    window.history.back()
