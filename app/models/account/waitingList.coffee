ChaplinModel = require 'chaplin/models/model'
util = require 'lib/util'
config = require 'config'
module.exports = class WaitingList extends ChaplinModel

  initialize: (attributes, option) ->
    super
    @subscribeEvent 'showWaitingList', @getWaitingList
    @subscribeEvent 'completeWaitingList', @completeWaitingList

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
        modelData = {waitingListItems: data.response}
        @publishEvent 'completeWaitingList', modelData

      error: (xhr, textStatus, errorThrown) ->
        error = JSON.parse(xhr.responseText)
        alert error.meta.message


  completeWaitingList: (data) ->
    console.log ['Datos waiting list', data]
    model = {}
    model.waitingListItems = data.waitingListItems
    #model.status = data.status
    #model.sort = data.sort
    console.log ['items', model]
    @set model
    @publishEvent 'waitingListReady'

  set: (args) ->
    super            ###
