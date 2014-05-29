'use strict'
View = require 'views/base/view'
utils = require 'lib/utils'
$ = Winbits.$
env = Winbits.env

module.exports = class SocialMediaView extends View
  container: '#wb-profile'
  id : 'wbi-social-accounts-panel'
  template: require './templates/social-accounts'

  initialize: ->
    super
    @listenTo @model,  'change', -> @render()
    @delegate 'click', '.wbc-facebook-link', @doLinkFacebook
    @delegate 'click', '.wbc-facebook-unlink', @doUnlinkFacebook
    @delegate 'click', '.wbc-twitter-link', @doLinkTwitter
    @delegate 'click', '.wbc-twitter-unlink', @doUnlinkTwitter

  attach: ->
    super
    @$el.prop 'class', 'column'

  doLinkFacebook: (e)->
    e.preventDefault()
    utils.showAjaxLoading()
    @model.requestConnectionLink('facebook', context: @)
      .done(@successConnectFacebookLink)
      .fail(@showErrorMessageLinkSocialAccount)

  successConnectFacebookLink: (data)->
    popup =  window.open("", "facebook", "menubar=0,resizable=0,width=800,height=500")
    popup.postMessage
    popup.window?.location.href = data.response.socialUrl
    popup.focus()
    timer = setInterval($.proxy(->
      @facebookLinkedInterval(popup, timer)
    , @), 100)

  facebookLinkedInterval: (popup, timer)->
    if popup.closed
      clearInterval timer
      @facebookStatusRpc()

  facebookStatusRpc:->
    env.get('rpc').facebookStatus $.proxy(@facebookStatusSuccess, @)

  facebookStatusSuccess: (response)->
    if response.status is "connected"
      @model.set 'Facebook', yes
    else
      @showErrorMessageLinkSocialAccount()
    utils.hideAjaxLoading()


  showErrorMessageLinkSocialAccount: ->
    utils.hideAjaxLoading()
    message = 'Para poder ligar tu cuenta de Facebook o Twitter debes terminar el proceso y aceptar todos los privilegios solicitados.'
    options = value:'Aceptar', title: 'Error al ligar red social', icon : 'iconFont-close'
    utils.showMessageModal(message, options)

  doUnlinkFacebook: (e)->
    e.preventDefault()
    @doShowConfirmSocialAccountDelete('Facebook')

  doLinkTwitter:  (e)->
    e.preventDefault()
    utils.showAjaxLoading()
    @model.requestConnectionLink('twitter', context: @)
    .done(@successConnectTwitterLink)
    .fail(@showErrorMessageLinkSocialAccount)

  successConnectTwitterLink: (data)->
    popup =  window.open("", "twitter", "menubar=0,resizable=0,width=800,height=500")
    popup.postMessage
    popup.window?.location.href = data.response.socialUrl
    popup.focus()
    timer = setInterval($.proxy(->
      @twitterLinkedInterval(popup, timer)
    , @), 100)

  twitterLinkedInterval: (popup, timer)->
    if popup.closed
      clearInterval timer
      @validTwitterAccount()

  validTwitterAccount:->
    @model.requestGetSocialAccounts(context:@)
      .done(@doValidateTwitterAccount)
      .fail(@showErrorMessageLinkSocialAccount)

  doValidateTwitterAccount: (data)->
    @validateChangeAccount(data.response.socialAccounts, 'Twitter')


  validateChangeAccount:(socialAccounts, name)->
    available = !@model.get name
    for socialAccount in socialAccounts
      if socialAccount.name == name
        if socialAccount.available == available
          @model.set name, available
        else
          @showErrorMessageLinkSocialAccount()
    utils.hideAjaxLoading()

  doUnlinkTwitter: (e)->
    e.preventDefault()
    @doShowConfirmSocialAccountDelete('Twitter')

  doShowConfirmSocialAccountDelete:(socialAccount)->
    utils.showAjaxLoading()
    message = "¿Estás seguro que deseas desligar tu cuenta de #{socialAccount.toLowerCase()}?"
    options =
      value: 'Aceptar'
      title: 'Desligar redes sociales'
      icon: 'iconFont-candado'
      context: @
      cancelAction: @doAlwaysDeleteSocialAccount
      onClosed: @doAlwaysDeleteSocialAccount
      acceptAction: () -> @doRequestDeleteSocialAccount(socialAccount)
    utils.showConfirmationModal(message, options)

  doRequestDeleteSocialAccount: (socialAccount)->
    @model.requestDeleteSocialAccount(socialAccount.toLowerCase(), context:@)
    .done(->
      @model.set socialAccount, no
      utils.closeMessageModal())
    .fail(@doFailDeleteSocialAccount)
    .always(@doAlwaysDeleteSocialAccount)

  doFailDeleteSocialAccount: ->
    message = 'El servidor no está disponible, por favor inténtalo más tarde.'
    options = value: "Cerrar"
    utils.showError(message, options)

  doAlwaysDeleteSocialAccount: ->
    utils.hideAjaxLoading()