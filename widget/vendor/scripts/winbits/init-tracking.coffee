'use strict'

Winbits.trackingUtils =
  UTM_PARAMS_KEY: 'utm-params'

  getURLParams: Winbits.utils.getURLParams

  parseUTMParams: ->
    params = @getURLParams()
    utms = {}
    for own key, value of params when key.indexOf('utm_') is 0
      utms[key] = value
    utms

  validateUTMParams: (utms) ->
    utms? and utms.utm_campaign? and utms.utm_medium?

  saveUTMParams: () ->
    utmParams = @parseUTMParams()
    Winbits.env.set(@UTM_PARAMS_KEY, utmParams) if @validateUTMParams(utmParams)

Winbits.trackingUtils.saveUTMParams()
