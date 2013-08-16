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

  getHistorical: (formData) ->
    console.log ['formdata', formData]
    url = config.apiUrl + "/affiliation/orders.json?"
    status = ""
    sort = ""
    if (formData?)
      url += "status=" + formData.status + "&sort=" + formData.sort
      status = formData.status
      sort = formData.sort

    Backbone.$.ajax url,
      type: "GET"
      contentType: "application/json"
      dataType: "json"
      #data: JSON.stringify(formData)
      context: @
      headers:
        "Accept-Language": "es"
        "WB-Api-Token":  util.getCookie(config.apiTokenName)

      success: (data) ->
        modelData = {orders: data.response, status: status, sort: sort}
        @set @completeOrdersHistory(modelData)
        @publishEvent 'orderRecordReady'

      error: (xhr, textStatus, errorThrown) ->
        error = JSON.parse(xhr.responseText)
        alert error.meta.message


  completeOrdersHistory: (data) ->
    model = {}
    model.orders = data.orders
    model.status = data.status
    model.sort = data.sort
    model

  set: (args) ->
    super
