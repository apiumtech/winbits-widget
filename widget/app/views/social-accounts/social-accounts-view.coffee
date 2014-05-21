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

  attach: ->
    super
    @$el.prop 'class', 'column'


