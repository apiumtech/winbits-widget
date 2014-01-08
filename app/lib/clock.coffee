util = require 'lib/util'
config = require 'config'

module.exports =

  startCounter: ($timer) ->
    that = @
    console.log(["The timer", $timer])
    $interval = setInterval () ->
      that.updateCheckoutTimer($timer, $interval)
    , 1000

  updateCheckoutTimer: ($timer, $interval) ->

    $ = Backbone.$
    $main = $('main').first()
    $container = $main.find($timer.data('contentTimerId'))
    if $container.is(':hidden')
      clearInterval $interval

    minutes = $timer.data('minutes')
    minutes = if minutes? then minutes else 30
    seconds = $timer.data('seconds') || 0
    seconds = seconds - 1
    if minutes is 0 and seconds < 0
      console.log ['expire order', $timer.data('orderId')]
      @expireOrder $timer.data('orderId')
      clearInterval $interval
      util.showError("Tu orden ha expirado")
    else
      if seconds < 0
        seconds = 59
        minutes = minutes - 1
      $timer.data('minutes', minutes)
      $timer.data('seconds', seconds)
      $timer.text @formatTime(minutes) + ':' + @formatTime(seconds)

  formatTime: (time) ->
    ('0' + time).slice(-2)

  expireOrder: (orderId) ->
    console.log ['Expire Order id', orderId]
    url = config.apiUrl + "/orders/orders/"+orderId+"/rollback.json"
    Backbone.$.ajax url,
      type: "POST"
      contentType: "application/json"
      dataType: "json"
      context: @
      headers:
        "Accept-Language": "es",
        "WB-Api-Token": util.retrieveKey(config.apiTokenName)
      success: (data) ->
        console.log ["expire order Success!", data]
        util.backToSite()

      error: (xhr) ->
        util.showAjaxError(xhr.responseText)

      complete: ->
        console.log "Request Completed!"