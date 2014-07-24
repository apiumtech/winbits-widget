'use strict'

Winbits.trackingUtils =
  UTMS_KEY: 'utms'

  URL_CONTAINS_VALID_UTMS: no

  getURLParams: Winbits.utils.getURLParams

  parseUTMParams: ->
    params = @getURLParams()
    utms = {}
    suffix = 'utm_'
    for own key, value of params when key.indexOf(suffix) is 0
      newKey = key.substring(suffix.length)
      utms[newKey] = value
    utms

  validateUTMParams: (utms) ->
    utms? and utms.campaign? and utms.medium?

  saveUTMParams: ->
    utmParams = @parseUTMParams()
    if @validateUTMParams(utmParams)
      @URL_CONTAINS_VALID_UTMS = yes
      Winbits.env.set(@UTMS_KEY, utmParams)

  cacheUTMs: (utms) ->
    Winbits.env.set(@UTMS_KEY, utms) unless @URL_CONTAINS_VALID_UTMS

Winbits.trackingUtils.saveUTMParams()
