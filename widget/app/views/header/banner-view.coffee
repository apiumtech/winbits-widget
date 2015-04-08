View = require 'views/base/view'
env = Winbits.env
$ = Winbits.$

module.exports = class HeaderBannerView extends View
  container: '#wbi-banner-header'
  template: require './templates/banner'

  initialize: ->
    super
    @listenTo @model,  'change', -> @render()
    @delegate 'click', '#wbi-drop-down-link', @dropDown

  attach: ->
    super
    @$('.openClose').showHideDiv()

  dropDown : (e)->
    e.preventDefault()
    @$('.openClose').click()