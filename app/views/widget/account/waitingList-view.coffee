template = require 'views/templates/account/waiting-list'
View = require 'views/base/view'
util = require 'lib/util'
config = require 'config'

module.exports = class WaitingListView extends View
  autoRender: yes
  container: '#waitingListContent'
  template: template

  render: ->
    super

  initialize: ->
    super
    @delegate 'click', '.deleteWaitingListItem', @deleteWaitingListItem
    @subscribeEvent 'waitingListReady', @handlerModelReady

  attach: ->
    super

  handlerModelReady: ->
    @render()

  deleteWaitingListItem: (e) ->
    $currentTarget = @$(e.currentTarget)
    skuProfileId =  $currentTarget.attr("id").split("-")[1]
    url = config.apiUrl + "/affiliation/waiting-list-item/" + skuProfileId + ".json"

    Backbone.$.ajax url,
      type: "DELETE"
      contentType: "application/json"
      dataType: "json"
      context: @
      headers:
        "Accept-Language": "es"
        "WB-Api-Token":  util.getCookie(config.apiTokenName)

      success: (data) ->
        modelData = {waitingListItems: data.response}
        @publishEvent 'completeWaitingList', modelData

      error: (xhr, textStatus, errorThrown) ->
        error = JSON.parse(xhr.responseText)
        alert error.meta.message