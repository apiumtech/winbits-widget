'use strict'

View = require 'views/base/view'
utils = require 'lib/utils'
CheckoutTempTotalSubview = require 'views/checkout-temp/checkout-temp-total-sub-view'
mediator = Winbits.Chaplin.mediator
$ = Winbits.$
_ = Winbits._
env = Winbits.env

module.exports = class CheckoutTempView extends View
  container: env.get 'vertical-container'
  className: 'widgetWinbitsMain wbc-vertical-content'
  template: require './templates/checkout-temp'


  initialize:()->
    super
    @delegate 'click', '#wbi-return-site-btn', @backToVertical
    @delegate 'click', '#wbi-post-checkout-btn', @doToCheckout
    $('main .wrapper').hide()

  attach: ->
    super
    @startCounter()

  render: ->
    super
    subviewContainer = @$el.find('#wbi-checkout-temp-total-div').get(0)
    @subview 'checkout-temp-total', new CheckoutTempTotalSubview model:@model, container: subviewContainer

  startCounter: ->
    $timer = @$('#wb-checkout-timer')
    nowTime =_.now() #new Date().getTime()
    unless (mediator.data.get('checkout-timestamp') )
      mediator.data.set('checkout-timestamp', nowTime)
    timeUp = nowTime - (mediator.data.get 'checkout-timestamp')
    expireTime = 30 * 60 * 1000
    if (timeUp <= expireTime)
      timeLeft = expireTime - timeUp
      minutesLeft = Math.floor(timeLeft / 1000 / 60)
      minutesLeftMillis = minutesLeft * 1000 * 60
      secondsLeft = Math.floor((timeLeft - minutesLeftMillis) / 1000)
      $timer.data('minutes', minutesLeft)
      $timer.data('seconds', secondsLeft)

      $interval = setInterval($.proxy(->
        @updateCheckoutTimer($timer, $interval)
      , @), 1000)
      @.timerInterval = $interval
    else
#      util.showAjaxIndicator("La orden ha expirado")
      @intervalStop
      setTimeout () ->
        utils.redirectToLoggedInHome()
      , 4000


  updateCheckoutTimer: ($timer, $interval) ->
    minutes = $timer.data('minutes')
    minutes = if minutes? then minutes else 30
    seconds = $timer.data('seconds') || 0
    seconds = seconds - 1

    if minutes is 0 and seconds < 0
      console.log('expire order')
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

  backToVertical: ->
    utils.restoreVerticalContent('.widgetWinbitsMain')
    $('main .wrapper').show()
    utils.redirectToLoggedInHome()

  doToCheckout: ->
    order = _.clone @model.attributes
    @model.postToCheckoutApp(order)


