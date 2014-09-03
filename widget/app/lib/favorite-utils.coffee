# wish-list-specific utilities
# --------------

utils = require 'lib/utils'
EventBroker = Winbits.Chaplin.EventBroker
$ = Winbits.$
env = Winbits.env
_ = Winbits._

wishListUtils = {}
_(wishListUtils).extend
  getWishListResourceUrl:(itemId) ->
    resource = if itemId then "/#{itemId}" else ''
    utils.getResourceURL("users/wish-list-items#{resource}.json")

  addToWishList: (options) ->
    options = options or {}
    utils.ajaxRequest(@getWishListResourceUrl(), @applyDefaultAddToWishListRequestDefaults(options))
    .done(@publishWishListChangeEvent)
    .fail(@showWishListErrorMessage)

  deleteFromWishList: (options) ->
    options = options or {}
    utils.ajaxRequest(@getWishListResourceUrl(options.brandId), @applyDefaultDeleteToWishListRequestDefaults(options))
    .done(@publishWishListChangeEvent)
    .fail(@showWishListErrorMessage)

  publishWishListChangeEvent: (data) ->
    EventBroker.publishEvent 'favorites-changed', data

  showWishListErrorMessage: (xhr, textStatus)->
    error = utils.safeParse(xhr.responseText)
    messageText = "Error actualizando el registro #{textStatus}"
    message = if error then error.meta.message else messageText
    options = icon:'iconFont-candado', value: "Cerrar", title:'Error'
    utils.showMessageModal(message, options)


  applyDefaultAddToWishListRequestDefaults: (options = {}) ->
    defaults =
      type: 'POST'
      data: JSON.stringify(brandId: options.brandId)
      context: @
      headers:
        'Wb-Api-Token': utils.getApiToken()
    requestOptions = $.extend({}, defaults, options)
    requestOptions.headers = $.extend({}, defaults.headers, options.headers)
    requestOptions

  applyDefaultDeleteToWishListRequestDefaults: (options = {}) ->
    defaults =
      type: 'DELETE'
      context: @
      headers:
        'Wb-Api-Token': utils.getApiToken()
    requestOptions = $.extend({}, defaults, options)
    requestOptions.headers = $.extend({}, defaults.headers, options.headers)
    requestOptions

#Prevent creating new properties and stuff
Object.seal? wishListUtils
module.exports = wishListUtils