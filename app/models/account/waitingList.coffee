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
    statusWaitingList = ""
    siteWaitingList = ""
    if (formData?)
      statusWaitingList = formData.statusWaitingList
      siteWaitingList = formData.siteWaitingList
      url += "status=" + statusWaitingList + "&site=" + siteWaitingList

    Backbone.$.ajax url,
      type: "GET"
      contentType: "application/json"
      dataType: "json"
      context: @
      headers:
        "Accept-Language": "es"
        "WB-Api-Token":  util.getCookie(config.apiTokenName)

      success: (data) ->
        modelData = {waitingListItems: data.response, status: statusWaitingList, site: siteWaitingList}
        @publishEvent 'completeWaitingList', modelData

      error: (xhr, textStatus, errorThrown) ->
        error = JSON.parse(xhr.responseText)
        alert error.meta.message


  completeWaitingList: (data) ->
    model = {}
    model.waitingListItems = data.waitingListItems
    model.statusWaitingList = data.status
    model.siteWaitingList = data.site
    @set model
    @publishEvent 'waitingListReady'

  set: (args) ->
    super            ###