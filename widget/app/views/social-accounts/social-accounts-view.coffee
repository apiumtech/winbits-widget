'use strict'
View = require 'views/base/view'
utils = require 'lib/utils'
$ = Winbits.$
env = Winbits.env

module.exports = class SocialMediaView extends View
  container: '#wb-profile'
  id : 'wbi-social-media-panel'
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
    @model.requestConnectionLink('facebook', context: @)
      .done(@successConnectLink)

  successConnectLink: (data)->
    popup =  window.open("", "facebook", "menubar=0,resizable=0,width=800,height=500")
    popup.postMessage
    popup.window.location.href = data.response.socialUrl
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
      console.log ['FBEst', response]
      @model.set 'facebook', yes
    else
      console.log "not conected to facebook "

  doUnlinkFacebook: (e)->
    e.preventDefault()

  doLinkTwitter: (e)->
    e.preventDefault()

  doUnlinkTwitter: (e)->
    e.preventDefault()
