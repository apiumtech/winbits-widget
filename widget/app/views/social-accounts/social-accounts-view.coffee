'use strict'
View = require 'views/base/view'
utils = require 'lib/utils'
$ = Winbits.$
_ = Winbits._
mediator = Winbits.Chaplin.mediator
env = Winbits.env

module.exports = class SocialMediaView extends View
  container: '#wb-profile'
  id : 'wbi-social-accounts-panel'
  template: require './templates/social-accounts'

  DEFAULT_ERROR_MESSAGE =
    DAFL : 'Para poder ligar tu cuenta de facebook debes terminar el proceso y aceptar todos los privilegios solicitados.'
    DPFL : 'Para poder ligar tu cuenta de facebook debes terminar el proceso y aceptar todos los privilegios solicitados.'
    DATL : 'Para poder ligar tu cuenta de twitter debes terminar el proceso y aceptar todos los privilegios solicitados.'
    FHLA : 'No es posible ligar la cuenta debido a que ya se encuentra ligada a otro usuario.'
    THLA : 'No es posible ligar la cuenta debido a que ya se encuentra ligada a otro usuario.'

  initialize: ->
    super
    @listenTo @model,  'change', -> @render()
    @delegate 'click', '.wbc-facebook-link', @doLinkFacebook
    @delegate 'click', '.wbc-facebook-unlink', @doUnlinkFacebook
    @delegate 'click', '.wbc-twitter-link', @doLinkTwitter
    @delegate 'click', '.wbc-twitter-unlink', @doUnlinkTwitter
    @subscribeEvent 'success-authentication-fb-link', -> @LinkStatusSuccess.apply(@, arguments)
    @subscribeEvent 'success-authentication-tw-link', -> @LinkStatusSuccess.apply(@, arguments)
    @subscribeEvent 'denied-authentication-fb-link', -> @doSocialLinkError.apply(@, arguments)
    @subscribeEvent 'denied-authentication-tw-link', -> @doSocialLinkError.apply(@, arguments)
    @subscribeEvent 'fb-has-link-account', -> @doSocialLinkError.apply(@, arguments)
    @subscribeEvent 'tw-has-link-account', -> @doSocialLinkError.apply(@, arguments)
    @subscribeEvent 'denied-permissions-fb-link', -> @doSocialLinkError.apply(@, arguments)

  attach: ->
    super
    @$el.prop 'class', 'column'

  doLinkFacebook: (e)->
    e.preventDefault()
    utils.showAjaxLoading()
    @popup =  window.open("", "facebook", "menubar=0,resizable=0,width=980,height=500")
    options = {context: @, data: JSON.stringify({verticalId:env.get('current-vertical-id')})}
    @model.requestConnectionLink('facebook', options)
      .done(@successConnectLink)
      .fail(@doFailDeleteSocialAccount)

  successConnectLink: (data)->
    @popup.window?.location.href = data.response.socialUrl
    @popup.focus()
    timer = setInterval($.proxy(->
      @socialLinkedInterval(@popup, timer)
    , @), 100)

  socialLinkedInterval: (popup, timer)->
    if popup.closed
      clearInterval timer
      utils.hideAjaxLoading()

  LinkStatusSuccess: (data)->
    @model.set data.successCode, yes
    @doChangeLoginSocialAccounts()

  doUnlinkFacebook: (e)->
    e.preventDefault()
    @doShowConfirmSocialAccountDelete('Facebook')

  doLinkTwitter:  (e)->
    e.preventDefault()
    utils.showAjaxLoading()
    @popup =  window.open("", "twitter", "menubar=0,resizable=0,width=980,height=500")
    options = {context: @, data: JSON.stringify({verticalId:env.get('current-vertical-id')})}
    @model.requestConnectionLink('twitter', options)
    .done(@successConnectLink)
    .fail(@doFailDeleteSocialAccount)

  doUnlinkTwitter: (e)->
    e.preventDefault()
    @doShowConfirmSocialAccountDelete('Twitter')

  doShowConfirmSocialAccountDelete:(socialAccount)->
    message = "¿Estás seguro que deseas desligar tu cuenta de #{socialAccount.toLowerCase()}?"
    options =
      value: 'Aceptar'
      title: 'Desligar redes sociales'
      icon: 'iconFont-candado'
      context: @
      cancelAction: @doCancelDeleteSocialAccount
      onClosed: @doCancelDeleteSocialAccount
      acceptAction: () -> @doRequestDeleteSocialAccount(socialAccount)
    utils.showConfirmationModal(message, options)


  doRequestDeleteSocialAccount: (socialAccount)->
    utils.showAjaxLoading()
    @socialAccount = socialAccount
    @model.requestDeleteSocialAccount(socialAccount.toLowerCase(), context:@)
    .done(@doShowMessageSuccess)
    .fail(@doFailDeleteSocialAccount)
    .always(@doAlwaysDeleteSocialAccount)

  doShowMessageSuccess: ->
    @model.set @socialAccount, no
    message = 'Tus datos se han guardado correctamente.'
    options = value: "Cerrar", title: "Datos guardados",  icon: 'iconFont-ok'
    utils.showMessageModal(message, options)

  doFailDeleteSocialAccount: ->
    message = 'El servidor no está disponible, por favor inténtalo más tarde.'
    options = value: "Cerrar"
    utils.showError(message, options)

  doAlwaysDeleteSocialAccount: ->
    utils.hideAjaxLoading()
    @doChangeLoginSocialAccounts()

  doCancelDeleteSocialAccount: ->
    utils.hideAjaxLoading()
    utils.closeMessageModal()

  doSocialLinkError: (data)->
    message = DEFAULT_ERROR_MESSAGE[data.errorCode]
    options =
      value : 'Aceptar'
      title : 'Error al ligar red social'
      icon  : "iconFont-#{data.accountId}Circle"
      context: @
    utils.showMessageModal(message, options)

  doChangeLoginSocialAccounts: ->
    $loginData = _.clone mediator.data.get('login-data')
    $accountStatus = @model.attributes;
    for socialAccount in $loginData.socialAccounts
      if socialAccount.name is 'Facebook'
        socialAccount.available = $accountStatus.Facebook
      else
        socialAccount.available = $accountStatus.Twitter
    mediator.data.set 'login-data', $loginData
