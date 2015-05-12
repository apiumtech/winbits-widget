

ChaplinModel = require 'chaplin/models/model'
config = require 'config'
util = require 'lib/util'
module.exports = class Cards extends ChaplinModel

  constructor: (args) ->
    super
    args = args or {}
    @loadingIndicator = args.loadingIndicator is yes
    @mainOnClick = args.mainOnClick is yes
    if @mainOnClick
      @cardItemLegend = 'Establecer como tarjeta principal'
    else
      @cardItemLegend = 'Paga con esta tarjeta'

  initialize: () ->
    super
    @subscribeEvent 'showCardsManager', @getCards
    @subscribeEvent "orderBitsUpdated", @updateBitsParser

  getCards: ()->
    that = @
    url = config.apiUrl + "/orders/card-subscription.json"
    util.showAjaxIndicator('Cargando tarjetas guardadas...') if @loadingIndicator
    util.ajaxRequest( url,
      type: "GET"
      contentType: "application/json"
      dataType: "json"
      headers:
        "Accept-Language": "es"
        "WB-Api-Token":  util.retrieveKey(config.apiTokenName)
      success: (data) ->
        that.set cards: data.response, cardItemLegend: that.cardItemLegend
      error: (xhr) ->
        util.showAjaxError(xhr.responseText)
      complete: ->
        util.hideAjaxIndicator() if that.loadingIndicator
    )

  getCardsCompleteFromCyberSource: (subscriptionId)->
    that = @
    url = config.apiUrl + "/orders/card-complete-subscription?subscriptionId=#{subscriptionId}"
    util.showAjaxIndicator('Cargando tarjetas guardadas...') if @loadingIndicator
    util.ajaxRequest( url,
      type: "GET"
      async: false
      contentType: "application/json"
      dataType: "json"
      headers:
        "Accept-Language": "es"
        "WB-Api-Token":  util.retrieveKey(config.apiTokenName)
    )

  updateBitsParser: (response) ->
      @set methods:response.paymentMethods
