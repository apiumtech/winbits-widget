ChaplinModel = require 'chaplin/models/model'
util = require 'lib/util'
config = require 'config'
module.exports = class WaitingList extends ChaplinModel

  initialize: (attributes, option) ->
    super
    @subscribeEvent 'showWishList', @getWishList
    @subscribeEvent 'completeWishList', @completeWishList

  parse: (response) ->
    console.log ("Wish List: parse")
    response

  render: ->
    super

  getWishList: ->
    util.showAjaxIndicator()
    that = @
    url = config.apiUrl + "/affiliation/wish-list-items.json?"
    util.ajaxRequest( url,
      type: "GET"
      contentType: "application/json"
      dataType: "json"
      headers:
        "Accept-Language": "es"
        "WB-Api-Token":  util.retrieveKey(config.apiTokenName)

      success: (data) ->
        modelData = {brands: data.response}
        that.publishEvent 'completeWishList' , modelData
      error: (xhr, textStatus, errorThrown) ->
        util.showAjaxError(xhr.responseText)
      complete: ->
        util.hideAjaxIndicator()
    )

  completeWishList: (data) ->
    model = {}
    model.brands = data.brands
    @set model
    @publishEvent 'wishListReady'

  set: (args) ->
    super            ###
