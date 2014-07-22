'use strict'

# Tracking-specific utilities
# ------------------------------

utils = require 'lib/utils'
mediator = Chaplin.mediator
rpc = Winbits.env.get('rpc')
_ = Winbits._

UTMS_MEDIATOR_KEY = 'utms'

trackingUtils = {}
_(trackingUtils).extend

  saveUTMsIfAvailable: ->
    utms = @getUTMParams()
    if @validateUTMParams(utms)
      @saveUTMs(utms)
    else
      null

  getUTMParams: ->
    params = utils.getUrlParams()
    utms = {}
    for own key, value of params when key.indexOf('utm_') is 0
      utms[key] = value
    utms

  validateUTMParams: (utms) ->
    utms? and utms.utm_campaign? and utms.utm_medium?

  getUTMs: (callback, context = @) ->
    mediator.data.get(UTMS_MEDIATOR_KEY)

  saveUTMs: (utms) ->
    @cacheUTMs(utms)
    rpc.saveUTMs(utms)
    utms

  cacheUTMs: (utms) ->
    mediator.data.set(UTMS_MEDIATOR_KEY, utms)

# Prevent creating new properties and stuff.
Object.seal? trackingUtils

module.exports = trackingUtils
