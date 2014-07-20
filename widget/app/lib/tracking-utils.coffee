'use strict'

# Tracking-specific utilities
# ------------------------------

utils = require 'lib/utils'
rpc = Winbits.env.get('rpc')
_ = Winbits._

trackingUtils = {}
_(trackingUtils).extend

  saveUtmsIfAvailable: ->
    utms = @getUtmParams()
    if @validateUtmParams(utms)
      rpc.saveUtms(utms)

  getUtmParams: ->
    params = utils.getUrlParams()
    utms = {}
    for own key, value of params when key.indexOf('utm_') is 0
      utms[key] = value
    utms

  validateUtmParams: (utms) ->
    utms? and utms.utm_campaign? and utms.utm_medium?

  getUtms: (callback, context = @) ->
    rpc.getUtms _.bind(callback, context)

# Prevent creating new properties and stuff.
Object.seal? trackingUtils

module.exports = trackingUtils
