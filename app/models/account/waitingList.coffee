ChaplinModel = require 'chaplin/models/model'
util = require 'lib/util'
config = require 'config'
module.exports = class WaitingList extends ChaplinModel

  initialize: (attributes, option) ->
    super
    @url = config.apiUrl + "/affiliation/orders.json"
    @subscribeEvent 'showWaitingList', @getWaitingList

  parse: (response) ->
    console.log ("Waiting List: parse")
    response

  render: ->
    super

  getWaitingList: (formData) ->
    console.log ['formdata', formData]
    url = config.apiUrl + "/affiliation/waiting-list-items.json?"
    ###
    status = ""
    sort = ""
    if (formData?)
      url += "status=" + formData.status + "&sort=" + formData.sort
      status = formData.status
      sort = formData.sort
       ###
    Backbone.$.ajax url,
      type: "GET"
      contentType: "application/json"
      dataType: "json"
      context: @
      headers:
        "Accept-Language": "es"
        "WB-Api-Token":  util.getCookie(config.apiTokenName)

      success: (data) ->
        #modelData = {orders: data.response, status: status, sort: sort}
        modelData = {waitingListitems: data.response}
        @set @completeOrdersHistory(modelData)
        @publishEvent 'orderRecordReady'

      error: (xhr, textStatus, errorThrown) ->
        error = JSON.parse(xhr.responseText)
        alert error.meta.message


  completeOrdersHistory: (data) ->
    console.log ['Datos waiting list', data]
    model = {}
    model.waitingListitems = data.items
    #model.status = data.status
    #model.sort = data.sort
    model

  set: (args) ->
    super            ###
