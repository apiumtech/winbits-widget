View = require 'views/base/view'
utils = require 'lib/utils'

module.exports = class SocialMediaView extends View
  container: '#wbi-my-profile'
  id : 'wbi-social-media-panel'
  template: require './templates/social-media'

  attach: ->
    super
    @$el.prop 'class', 'column'


