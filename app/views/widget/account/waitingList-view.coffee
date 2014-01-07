template = require 'views/templates/account/waiting-list'
View = require 'views/base/view'
util = require 'lib/util'
config = require 'config'
vendor = require 'lib/vendor'

module.exports = class WaitingListView extends View
  autoRender: yes
  container: '#waitingListContent'
  template: template

  render: ->
    super

  initialize: ->
    super
    @delegate 'change', '.waitingListFilter', @filterWaitingList
    @delegate 'click', '.deleteWaitingListItem', @deleteWaitingListItem
    @subscribeEvent 'waitingListReady', @handlerModelReady

  attach: ->
    super
    vendor.customSelect(@$('.select'))

  handlerModelReady: ->
    @render()

  deleteWaitingListItem: (e) ->
    $currentTarget = @$(e.currentTarget)
    skuProfileId =  $currentTarget.attr("id").split("-")[1]
    url = config.apiUrl + "/affiliation/waiting-list-item/" + skuProfileId + ".json"
    that=@
    util.ajaxRequest( url,
      type: "DELETE"
      contentType: "application/json"
      dataType: "json"
#      context: @
      headers:
        "Accept-Language": "es"
        "WB-Api-Token":  util.getCookie(config.apiTokenName)
      success: (data) ->
        modelData = {waitingListItems: data.response}
        that.publishEvent 'completeWaitingList', modelData
      error: (xhr, textStatus, errorThrown) ->
        util.showAjaxError(xhr.responseText)
    )

  filterWaitingList: (e) ->
     e.preventDefault()
     $form = @$el.find("#waitingListFilterForm")
     formData = util.serializeForm($form)
     @publishEvent 'showWaitingList', formData
