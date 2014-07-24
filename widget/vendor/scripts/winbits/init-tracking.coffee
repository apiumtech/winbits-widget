'use strict'

Winbits.trackingUtils =
  UTMS_KEY: 'utms'

  URL_CONTAINS_VALID_UTMS: no

  getURLParams: Winbits.utils.getURLParams

  parseUTMParams: ->
    params = @getURLParams()
    utms = {}
    for own key, value of params when key.indexOf('utm_') is 0
      utms[key] = value
    utms

  validateUTMParams: (utms) ->
    utms? and utms.utm_campaign? and utms.utm_medium?

  saveUTMParams: ->
    utmParams = @parseUTMParams()
    if @validateUTMParams(utmParams)
      @URL_CONTAINS_VALID_UTMS = yes
      Winbits.env.set(@UTMS_KEY, utmParams)

  cacheUTMs: (utms) ->
    Winbits.env.set(@UTMS_KEY, utms) unless @URL_CONTAINS_VALID_UTMS

Winbits.trackingUtils.saveUTMParams()
