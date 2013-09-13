ChaplinModel = require 'chaplin/models/model'
config = require 'config'
util = require 'lib/util'
module.exports = class Cards extends ChaplinModel

  initialize: (attributes, option) ->
    super
    @url = config.apiUrl + "/orders/card-subscription.json"
    @refresh()

  parse: (response) ->
    cards : response.response

  refresh : ()->
    @fetch
      error: ->
        console.log "error cart",
          headers:{ 'Accept-Language': 'es', "WB-Api-Token": util.getCookie(config.apiTokenName)}
          success: ->
        console.log "success load Virtual cart"