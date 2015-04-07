'use strict'

utils = require 'lib/utils'
trackingUtils = require 'lib/tracking-utils'
mediator = Chaplin.mediator
$ = Winbits.$
_ = Winbits._
env = Winbits.env

newsLettersUtils = {}
_(newsLettersUtils).extend
   addUserToBebitos: (options) ->
     console.log(['addUserToBebitos'])
     $loginData = mediator.data.get 'login-data'
     defaults =
       type: "POST"
       contentType: "application/json"
       dataType: "json"
       data: JSON.stringify(email: $loginData.email)
       headers:
         "Accept-Language": "es",
         "WB-Api-Token": utils.getApiToken()
     utils.ajaxRequest(env.get('api-url') + "/users/addbebitos-newsletters",
       $.extend(defaults, options))
     .done(@sendSuccess)
     .fail(@sendError)

    sendSuccess:(data)->
      message = "Te has suscrito al boletín de bebitos."
      options = value: "Cerrar", title:'¡ Listo !', icon:'iconFont-ok', onClosed: utils.redirectToLoggedInHome()
      utils.showMessageModal(message, options)

   sendError: (xhr)->
     error = utils.safeParse(xhr.responseText)
     messageText = "En este momento no es posible suscribirte al boletìn de bebitos, favor de intentarlo más tarde"
     message = if error then error.meta.message else messageText
     options = value: "Cerrar", title:'Error', icon:'iconFont-info', onClosed: utils.redirectToLoggedInHome()
     utils.showMessageModal(message, options)


# Prevent creating new properties and stuff.
Object.seal? newsLettersUtils

module.exports = newsLettersUtils
