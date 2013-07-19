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


  showStep: (selector)->
    console.log @$(".chk-step")
    @$(".chk-step").hide()
    @$(selector).show()
  hideAddress: ()->
    @$(".checkoutShipping").hide()
    @$("#circuledNumber2").html("1")
    @$("#circuledNumber3").html("2")

  attach: () ->
    super
    @startCounter()

  startCounter: () ->
    that = @
    $timer = @$el.find('#wb-checkout-timer')
    console.log(["The timer", $timer])
    setInterval () ->
      that.updateCheckoutTimer($timer)
    , 1000

  updateCheckoutTimer: ($timer) ->
    minutes = $timer.data('minutes') || 30
    seconds = $timer.data('seconds') || 0
    seconds = seconds - 1
    if seconds < 0
      seconds = 59
      minutes = minutes - 1
    minutes = if minutes < 0 then 0 else minutes
    $timer.data('minutes', minutes)
    $timer.data('seconds', seconds)
    $timer.text @formatTime(minutes) + ':' + @formatTime(seconds)

  formatTime: (time) ->
    ('0' + time).slice(-2)
