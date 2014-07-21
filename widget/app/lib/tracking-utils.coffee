'use strict'

# Tracking-specific utilities
# ------------------------------

utils = require 'lib/utils'
rpc = Winbits.env.get('rpc')
_ = Winbits._

trackingUtils = {}
_(trackingUtils).extend

  saveUTMsIfAvailable: ->
    utms = @getUTMParams()
    if @validateUTMParams(utms)
      @saveUTMs(utms)

  getUTMParams: ->
    params = utils.getUrlParams()
    utms = {}
    for own key, value of params when key.indexOf('utm_') is 0
      utms[key] = value
    utms

  validateUTMParams: (utms) ->
    utms? and utms.utm_campaign? and utms.utm_medium?

  getUTMs: (callback, context = @) ->
    rpc.getUTMs _.bind(callback, context)

  saveUTMs: (utms) ->
    rpc.saveUTMs(utms)

# Prevent creating new properties and stuff.
Object.seal? trackingUtils

module.exports = trackingUtils
