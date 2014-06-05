# sku-profile-specific utilities
# --------------

utils = require 'lib/utils'
EventBroker = Winbits.Chaplin.EventBroker
$ = Winbits.$
env = Winbits.env
_ = Winbits._
mediator = Winbits.Chaplin.mediator

skuProfileUtils = {}
_(skuProfileUtils).extend
  getSkuProfileResourceUrl:(itemId) ->
    resource = if itemId then "/#{itemId}/" else '-'
    utils.getResourceURL("catalog/sku-profiles#{resource}info.json")

  getSkuProfileInfo: (options) ->
    options = options or {}
    if not options.id
      throw "Argument 'id' is required!"
    if utils.isLoggedIn()
      options.headers = 'Wb-Api-Token': utils.getApiToken()
    data = if utils.isLoggedIn() then {userId: mediator.data.get('login-data').id} else {}
    utils.ajaxRequest(@getSkuProfileResourceUrl(options.id), @applyDefaultPostSkuProfile(data, options))
    .done(@skuProfileSuccessRequest)
    .fail(@skuProfileErrorRequest)

  getSkuProfilesInfo: (options) ->
    options = options or {}
    if not options.ids
      throw "Argument 'ids' is required!"
    if utils.isLoggedIn()
      options.headers = 'Wb-Api-Token': utils.getApiToken()
    data = if utils.isLoggedIn() then {userId: mediator.data.get('login-data').id} else {}
    data.ids = options.ids.join()
    utils.ajaxRequest(@getSkuProfileResourceUrl(), @applyDefaultPostSkuProfile(data, options))
    .done(@skuProfileSuccessRequest)
    .fail(@skuProfileErrorRequest)

  skuProfileSuccessRequest: ->
    console.log ["Carga de sku profile exitosa"]

  skuProfileErrorRequest: (xhr, textStatus)->
    console.log ["Carga de sku profile fallida"]

  applyDefaultPostSkuProfile: (formData, options = {}) ->
    defaults =
      type: 'POST'
      data: JSON.stringify(formData)
    requestOptions = $.extend({}, defaults, options)
    requestOptions.headers = $.extend({}, defaults.headers, options.headers)
    requestOptions


#Prevent creating new properties and stuff
Object.seal? skuProfileUtils
module.exports = skuProfileUtils