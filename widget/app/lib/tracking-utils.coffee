'use strict'

# Tracking-specific utilities
# ------------------------------
utils = require 'lib/utils'
mediator = Chaplin.mediator
env = Winbits.env
rpc = env.get('rpc')
_ = Winbits._

trackingUtils = {}
# Some functions are defined inside init-tracking.coffee
_(trackingUtils).extend Winbits.trackingUtils,

  saveUTMsIfNeeded: ->
    utms = @getUTMParams()
    if @shouldSaveUTMs()
      @saveUTMs(utms)
    env.set?(@UTMS_KEY, undefined)

  saveUTMs: (utms) ->
    mediator.data.set(@UTMS_KEY, utms)
    rpc.storeUTMs(utms)

  getUTMs: ->
    mediator.data.get(@UTMS_KEY)

  shouldSaveUTMs: ->
    @URL_CONTAINS_VALID_UTMS and not utils.isLoggedIn()

  deleteUTMs: ->
    rpc.removeUTMs()

  # Following functions are defined inside init-tracking.coffee:
  # getUTMParams
  # validateUTMParams
  # saveUTMParams

# Prevent creating new properties and stuff.
Object.seal? trackingUtils

delete Winbits.trackingUtils

module.exports = trackingUtils
