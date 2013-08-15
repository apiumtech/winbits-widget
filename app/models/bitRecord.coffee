ChaplinModel = require 'chaplin/models/model'
util = require 'lib/util'
config = require 'config'
module.exports = class BitRecord extends ChaplinModel

  initialize: (attributes, option) ->
    super
    @url = config.apiUrl + "/affiliation/bits.json"
    @subscribeEvent 'showHistorical', @getHistorical

  #@fetch success: (collection, response) ->
  #collection.resolve()
  parse: (response) ->
    console.log ("bit record: parse")
    response

  render: ->
    super

  getHistorical: (args) -> 
    Backbone.$.ajax config.apiUrl + "/affiliation/bits/transactions.json",
      type: "GET"
      contentType: "application/json"
      dataType: "json"
      #data: JSON.stringify(updateData)
      context: @
      headers:
        "Accept-Language": "es"
        "WB-Api-Token":  util.getCookie(config.apiTokenName)

      success: (data) ->
        console.log ["Success: Update  bits", data.response]
        @set @completeBitRecord(data.response)
        #@publishEvent('orderBitsUpdated', data.response)
        #if data.response.cashTotal is 0 
        #    @publishEvent('showBitsPayment')
        @publishEvent 'bitRecordReady'

      error: (xhr, textStatus, errorThrown) ->
        error = JSON.parse(xhr.responseText)
        alert error.meta.message

    console.log ["wee", args]

  completeBitRecord: (data) ->
      model = {}
      model.balance = data.balance
      model.transactions = data.transactions
      model.transactionsSize = data.transactions.length + 1
      model.test = 1000
      model
      

  set: (args) ->
    super