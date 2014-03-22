ChaplinModel = require 'chaplin/models/model'
util = require 'lib/util'
config = require 'config'
module.exports = class OrderHistory extends ChaplinModel

  initialize: (attributes, option) ->
    super
    @url = config.apiUrl + "/users/orders.json"
    @subscribeEvent 'showOrdersHistory', @getHistorical

  parse: (response) ->
    console.log ("Orders record: parse")
    response

  render: ->
    super

  getHistorical: (formData) ->
    console.log ['formdata', formData]
    url = config.apiUrl + "/users/orders.json?"
    status = ""
    sort = ""
    if (formData?)
      status = formData.status
      sort = formData.sort
      url += "status=" + status + "&sort=" + sort

    util.showAjaxIndicator()
    that=@
    util.ajaxRequest( url,
      type: "GET"
      contentType: "application/json"
      dataType: "json"
      headers:
        "Accept-Language": "es"
        "WB-Api-Token":  util.retrieveKey(config.apiTokenName)

      success: (data) ->
        modelData = {orders: data.response, status: status, sort: sort}
        that.set that.completeOrdersHistory(modelData)
        that.publishEvent 'orderRecordReady'
      error: (xhr, textStatus, errorThrown) ->
        util.showAjaxError(xhr.responseText)
      complete: ->
        util.hideAjaxIndicator()
    )

  completeOrdersHistory: (data) ->
    model = {}
    model.orders = data.orders
    model.status = data.status
    model.sort = data.sort
    model

  set: (args) ->
    super
