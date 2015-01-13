###################################################################################################
#
# NombrerAchivo.coffee
# Descripción:
# Modelo asociado:
# Controlador asociado:
# Autor:
# Fecha de creación:
# Persona que modificó:
# Fecha de modificación:
# Descripción y motivo del cambio
#
###################################################################################################

utils = require 'lib/utils'
Model = require "models/base/model"
env = Winbits.env
mediator = Winbits.Chaplin.mediator
$ = Winbits.$

module.exports = class verifyMobile extends Model

  initialize: () ->
    super

###################################################################################################
  #
  # Nombre de la función
  # Descripción:
  # Tipo de dato de retorno:
  # Valor de retorno:
  # Descripción del valor de retorno:
  # Fecha de creación:
  # Persona que modificó:
  # Fecha de modificación:
  # Descripción y motivo del cambio
  #
  ###################################################################################################
  sendCodeForActivationMobile:(formData, options) ->
    loginData = mediator.data.get('login-data')
    $.extend(formData, cellphone: loginData.profile.phone)
    defaults =
      contentType: "application/json"
      dataType: "json"
      data: JSON.stringify(formData)
      headers:
         "Accept-Language": "es",
         "WB-Api-Token": utils.getApiToken()

    utils.ajaxRequest(env.get('api-url') + "/users/activate-mobile/#{formData.cellphone}/#{formData.code}",
    $.extend(defaults, options))

###################################################################################################
  #
  # Nombre de la función
  # Descripción:
  # Tipo de dato de retorno:
  # Valor de retorno:
  # Descripción del valor de retorno:
  # Fecha de creación:
  # Persona que modificó:
  # Fecha de modificación:
  # Descripción y motivo del cambio
  #
  ###################################################################################################
  reSendCodeToClient:(options) ->
    loginData = mediator.data.get('login-data')
    defaults =
      contentType: "application/json"
      dataType: "json"
      data: ""
      headers:
        "Accept-Language": "es",
        "WB-Api-Token": utils.getApiToken()
    utils.ajaxRequest(env.get('api-url') + "/users/send-sms/#{loginData.profile.phone}",
      $.extend(defaults, options))