template = require 'views/templates/account/wish-list'
View = require 'views/base/view'
util = require 'lib/util'
config = require 'config'

module.exports = class WishListView extends View
  autoRender: yes
  container: '#wishListContent'
  template: template

  render: ->
    super

  initialize: ->
    super
    @delegate 'click', '.deleteWishListItem', @deleteWishListItem
    @subscribeEvent 'wishListReady', @handlerModelReady

  attach: ->
    super

  handlerModelReady: ->
    @render()

  deleteWishListItem: (e) ->
    $currentTarget = @$(e.currentTarget)
    brandId =  $currentTarget.attr("id").split("-")[1]
    url = config.apiUrl + "/users/wish-list-items/" + brandId + ".json"
    that=@
    util.ajaxRequest( url,
      type: "DELETE"
      contentType: "application/json"
      dataType: "json"
#      context: @
      headers:
        "Accept-Language": "es"
        "WB-Api-Token":  util.retrieveKey(config.apiTokenName)

      success: (data) ->
        modelData = {brands: data.response}
        that.publishEvent 'completeWishList', modelData
      error: (xhr, textStatus, errorThrown) ->
        util.showAjaxError(xhr.responseText)
    )