module.exports =

  startCounter: ($timer) ->
    that = @
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