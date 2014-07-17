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
    rpc.saveUtms(utms) if @validateUtmParams(utms)

  getUtmParams: ->
    params = utils.getUrlParams()
    _.pick(params, ->
      key = arguments[1]
      key.indexOf('utm_') is 0
    )

  validateUtmParams: (utms) ->
    utms?

  getUtms: (callback, context = @) ->
    rpc.getUtms _.bind(callback, context)

# Prevent creating new properties and stuff.
Object.seal? trackingUtils

module.exports = trackingUtils
