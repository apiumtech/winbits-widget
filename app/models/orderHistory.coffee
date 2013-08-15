ChaplinModel = require 'chaplin/models/model'
util = require 'lib/util'
config = require 'config'
module.exports = class OrderHistory extends ChaplinModel

  initialize: (attributes, option) ->
    super
    @url = config.apiUrl + "/affiliation/orders.json"
    @subscribeEvent 'showOrdersHistory', @getHistorical

  #@fetch success: (collection, response) ->
  #collection.resolve()
  parse: (response) ->
    console.log ("Orders record: parse")
    response

  render: ->
    super

  getHistorical: (args) ->
    Backbone.$.ajax config.apiUrl + "/affiliation/orders.json",
      type: "GET"
      contentType: "application/json"
      dataType: "json"
    #data: JSON.stringify(updateData)
      context: @
      headers:
        "Accept-Language": "es"
        "WB-Api-Token":  util.getCookie(config.apiTokenName)

      success: (data) ->
        console.log ["Success: Update  Orders", data.response]
        @set @completeOrdersHistory(data.response)
        @publishEvent 'orderRecordReady'

      error: (xhr, textStatus, errorThrown) ->
        error = JSON.parse(xhr.responseText)
        alert error.meta.message

    console.log ["wee", args]

  completeOrdersHistory: (data) ->
    model = {}
    model.orders = data
    model


  set: (args) ->
    super
