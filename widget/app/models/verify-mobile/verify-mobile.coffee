###################################################################################################
#
# verify-mobile.coffee
# Descripción:   Archivo con las funcines de la vista para la activación del teléfono celular del usuario mediante envío de mensajes SMS desde el perfil de usurio (Mi cuenta)
#             Se utiliza para activar mediante el código que se envió al celular; reenviar el código al celular cuando no se ha activado y reenviar el código cuando se ha actualizado
#             el número de celular por parte del cliente.
# Vista asociada: verify-mobile-view
# Controlador asociado:  logged-in-controller
# Autor:      Renè Hernàndez
# Fecha de creación:   13/01/2015
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
  # sendCodeForActivationMobile
  # Autor:      Renè Hernàndez
  # Descripción:  Envía el código editado por el usuario para la activación del teléfono al servicio de la aplicación affilation-api.
  #               El còdigo lo toma del parámetro (forma) de entrada y el telèfono del profile de usuario
  # Parámetros:
  #       formData: Los datos enviados desde la vista
  #       options
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
      type: "POST"
      contentType: "application/json"
      dataType: "json"
      data: JSON.stringify(mobile: formData.cellphone, code: formData.code)
      headers:
        "Accept-Language": "es",
        "WB-Api-Token": utils.getApiToken()
    utils.ajaxRequest(env.get('api-url') + "/users/activate-mobile",
      $.extend(defaults, options))

###################################################################################################
  # reSendCodeToClient
  # Autor:      Renè Hernàndez
  # Descripción:  Envía el teléfono del usuario para para el reenvío del código por parte del servicio de la aplicación affilation-api.
  #               Toma el telèfono del profile de usuario
  # Parámetros:
  #       options
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