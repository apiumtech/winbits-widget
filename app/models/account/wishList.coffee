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
    url = config.apiUrl + "/affiliation/wish-list-items.json?"
    Backbone.$.ajax url,
      type: "GET"
      contentType: "application/json"
      dataType: "json"
      context: @
      headers:
        "Accept-Language": "es"
        "WB-Api-Token":  util.getCookie(config.apiTokenName)

      success: (data) ->
        modelData = {brands: data.response}
        @publishEvent 'completeWishList' , modelData

      error: (xhr, textStatus, errorThrown) ->
        error = JSON.parse(xhr.responseText)
        alert error.meta.message

  completeWishList: (data) ->
    model = {}
    model.brands = data.brands
    @set model
    @publishEvent 'wishListReady'

  set: (args) ->
    super            ###
