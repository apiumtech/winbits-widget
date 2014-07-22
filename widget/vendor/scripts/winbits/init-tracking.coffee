'use strict'

Winbits.trackingUtils =
  getURLParams: Winbits.utils.getURLParams

  getUTMParams: ->
    params = @getURLParams()
    utms = {}
    for own key, value of params when key.indexOf('utm_') is 0
      utms[key] = value
    utms

  validateUTMParams: (utms) ->
    utms? and utms.utm_campaign? and utms.utm_medium?

  saveUTMParams: () ->
    utmParams = @getUTMParams()
    Winbits.env.set('utm-params', utmParams) if @validateUTMParams(utmParams)

Winbits.trackingUtils.saveUTMParams()
