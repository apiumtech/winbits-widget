Model = require 'models/base/model'
Utils = require 'lib/utils'
env = Winbits.env
$ = Winbits.$

module.exports = class Header extends Model

  initialize: (data)->
    super
    if data?.verticalsData
      @set @parse
        meta: currentVerticalId: data.currentVerticalId
        response: data.verticalsData

  parse: (data) ->
    currentVerticalId: data.meta.currentVerticalId
    activeVerticals: data.response


  getPromo: (options) ->
    defaults =
      type: "POST"
      contentType: "application/json"
      dataType: "json"
      headers:
        "Accept-Language": "es"
    Utils.ajaxRequest(env.get('api-url')+"/users/promotions-widget",$.extend(defaults, options))

