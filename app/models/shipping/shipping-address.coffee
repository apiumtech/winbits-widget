ChaplinModel = require 'chaplin/models/model'
util = require 'lib/util'
config = require 'config'
module.exports = class ShippingAddress extends ChaplinModel

  initialize: (attributes, option) ->
    super
    @url = config.apiUrl + "/affiliation/shipping-addresses"
    @subscribeEvent 'completeShippingAddress', @completeShippingAddress
    @subscribeEvent 'showShippingAddresses', @getShippingAddressList

  parse: (response) ->
    console.log ("Wish List: parse")
    response

  render: ->
    super

  getShippingAddressList: ->
    that = @
    url = config.apiUrl + "/affiliation/shipping-addresses.json"
    Backbone.$.ajax url,
      type: "GET"
      contentType: "application/json"
      dataType: "json"
      context: @
      headers:
        "Accept-Language": "es"
        "WB-Api-Token":  util.retrieveKey(config.apiTokenName)

      success: (data) ->
        model = {}
        model.addresses = data.response
        that.set model
        that.publishEvent 'shippingReady'

      error: (xhr, textStatus, errorThrown) ->
        util.showAjaxError(xhr.responseText)

  completeShippingAddress: (data) ->
    console.log 'refrescando'

  set: (args) ->
    super            ###
