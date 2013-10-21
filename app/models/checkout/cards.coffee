ChaplinModel = require 'chaplin/models/model'
config = require 'config'
util = require 'lib/util'
module.exports = class Cards extends ChaplinModel

  constructor: (args) ->
    super
    args = args or {}
    @mainOnClick = args.mainOnClick is true
    if @mainOnClick
      @cardItemLegend = 'Establecer como tarjeta principal'
    else
      @cardItemLegend = 'Paga con esta tarjeta'

  initialize: () ->
    super
    @subscribeEvent 'showCardsManager', @getCards

  getCards: ()->
    url = config.apiUrl + "/orders/card-subscription.json"
    Backbone.$.ajax url,
      type: "GET"
      contentType: "application/json"
      dataType: "json"
      context: @
      headers:
        "Accept-Language": "es"
        "WB-Api-Token":  util.getCookie(config.apiTokenName)

      success: (data) ->
        console.log 'Success loading cards'
        @set cards: data.response, cardItemLegend: @cardItemLegend

      error: (xhr, textStatus, errorThrown) ->
        util.showAjaxError(xhr.responseText)
