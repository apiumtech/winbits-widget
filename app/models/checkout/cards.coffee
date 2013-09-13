ChaplinModel = require 'chaplin/models/model'
config = require 'config'
util = require 'lib/util'
module.exports = class Cards extends ChaplinModel

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
        this.set cards: data.response

      error: (xhr, textStatus, errorThrown) ->
        error = JSON.parse(xhr.responseText)
        alert error.meta.message