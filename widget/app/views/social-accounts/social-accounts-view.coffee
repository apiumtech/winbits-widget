'use strict'
View = require 'views/base/view'
utils = require 'lib/utils'

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
    console.log ['LIGAR CUENTA FB', e]

  doUnlinkFacebook: (e)->
    e.preventDefault()

  doLinkTwitter: (e)->
    e.preventDefault()

  doUnlinkTwitter: (e)->
    e.preventDefault()
