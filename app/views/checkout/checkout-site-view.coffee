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
    @subscribeEvent "StopIntervalTimer", @intervalStop
    @delegate "click","#showAddress", @showAddress
    @delegate 'click', '.close-modal', @closeModal
    @delegate 'click', 'i.close-icon', @closeModal
    @delegate 'click', '#wbi-winbits-logo', @onWinbitsLogoClick
    @delegate 'click', '.expire-close-modal', @closeExpireOrderModal
    @delegate 'click', '#expire-close-login', @closeExpireOrderModal


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
    Backbone.$('#wbi-expire-modal').modal({backdrop: 'static', keyboard: false, show: false})

  startCounter: () ->
    that = @
    $timer = @$el.find('#wb-checkout-timer')
    nowTime = new Date().getTime()
    timeUp =  nowTime - Winbits.checkoutConfig.timestamp
    expireTime = 30 * 60 * 1000
    if (timeUp <= expireTime)
      timeLeft = expireTime - timeUp
      minutesLeft = Math.floor(timeLeft / 1000 / 60)
      minutesLeftMillis = minutesLeft * 1000 * 60
      secondsLeft = Math.floor((timeLeft - minutesLeftMillis) / 1000)
      $timer.data('minutes', minutesLeft)
      $timer.data('seconds', secondsLeft)

      $interval = setInterval () ->
        that.updateCheckoutTimer($timer, $interval)
      , 1000
      @.timerInterval = $interval
    else
      util.showAjaxIndicator("La orden ha expirado")
      @intervalStop
      setTimeout () ->
        window.location.href = Winbits.checkoutConfig.verticalUrl
      , 4000

  closeExpireOrderModal: () ->
    @$('.modal').modal 'hide'
    util.redirectToVertical(Winbits.checkoutConfig.verticalUrl)

  updateCheckoutTimer: ($timer, $interval) ->
    minutes = $timer.data('minutes')
    minutes = if minutes? then minutes else 30
    seconds = $timer.data('seconds') || 0
    seconds = seconds - 1

    if minutes is 0 and seconds < 0
      console.log('expire order')
      Backbone.$('#wbi-expire-modal').modal('show')
      @intervalStop
    else

      if seconds < 0
        seconds = 59
        minutes = minutes - 1
      $timer.data('minutes', minutes)
      $timer.data('seconds', seconds)
      $timer.text @formatTime(minutes) + ':' + @formatTime(seconds)

  formatTime: (time) ->
    ('0' + time).slice(-2)

  intervalStop: ()->
    console.log 'Inteval Timer Stop !'
    clearInterval(@.timerInterval)

  onWinbitsLogoClick: (e) ->
    e.preventDefault()
    window.history.back()
