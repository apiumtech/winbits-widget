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
    if utils.isLoggedIn()
      options.headers = 'Wb-Api-Token': utils.getApiToken()
    data = if utils.isLoggedIn() then {userId: mediator.data.get('login-data').id} else {}
    utils.ajaxRequest(@getSkuProfileResourceUrl(options.id), @applyDefaultPostSkuProfile(data, options))
    .done(@publishSkuProfileChangeEvent)
    .fail(@showSkuProfileErrorMessage)

  getSkuProfilesInfo: (options) ->
    options = options or {}
    if not options.ids
      throw "Argument 'ids' is required!"
    if utils.isLoggedIn()
      options.headers = 'Wb-Api-Token': utils.getApiToken()
    data = if utils.isLoggedIn() then {userId: mediator.data.get('login-data').id} else {}
    data.ids = options.ids.join()
    utils.ajaxRequest(@getSkuProfileResourceUrl(), @applyDefaultPostSkuProfile(data, options))
    .done(@publishSkuProfileChangeEvent)
    .fail(@showSkuProfileErrorMessage)

  publishSkuProfileChangeEvent: ->
    console.log ["Carga de sku profile exitosa"]

  showSkuProfileErrorMessage: (xhr, textStatus)->
    error = utils.safeParse(xhr.responseText)
    messageText = "Error actualizando el registro #{textStatus}"
    message = if error then error.meta.message else messageText
    options = icon:'iconFont-candado', value: "Cerrar", title:'Error'
    utils.showMessageModal(message, options)

  applyDefaultPostSkuProfile: (formData, options = {}) ->
    console.log ['data', formData ]
    defaults =
      type: 'POST'
      data: JSON.stringify(formData)
    requestOptions = $.extend({}, defaults, options)
    requestOptions.headers = $.extend({}, defaults.headers, options.headers)
    requestOptions


#Prevent creating new properties and stuff
Object.seal? skuProfileUtils
module.exports = skuProfileUtils