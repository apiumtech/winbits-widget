'use strict'

# Tracking-specific utilities
# ------------------------------

mediator = Chaplin.mediator
rpc = Winbits.env.get('rpc')
_ = Winbits._

UTMS_MEDIATOR_KEY = 'utms'

trackingUtils = {}
# Some functions are defined inside init-tracking.coffee
_(trackingUtils).extend Winbits.trackingUtils,

  saveUTMsIfAvailable: ->
    utms = @getUTMParams()
    if @validateUTMParams(utms)
      @saveUTMs(utms)
    else
      null

  getUTMs: (callback, context = @) ->
    mediator.data.get(UTMS_MEDIATOR_KEY)

  saveUTMs: (utms) ->
    @cacheUTMs(utms)
    rpc.saveUTMs(utms)
    utms

  cacheUTMs: (utms) ->
    mediator.data.set(UTMS_MEDIATOR_KEY, utms)

  # Following functions are defined inside init-tracking.coffee:
  # getUTMParams
  # validateUTMParams
  # saveUTMParams

# Prevent creating new properties and stuff.
Object.seal? trackingUtils

delete Winbits.trackingUtils

module.exports = trackingUtils
