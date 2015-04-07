View = require 'views/base/view'
Header = require 'models/header/header'
HeaderBannerView = require 'views/header/banner-view'
env = Winbits.env
$ = Winbits.$

module.exports = class HeaderView extends View
  container: env.get 'widget-container'
  template: require './templates/header'
  model: new Header
    currentVerticalId: env.get 'current-vertical-id'
    verticalsData: env.get 'verticals-data'
    currentVertical: env.get 'current-vertical'

  initialize: ->
    super
    @getPromotions()
    @subscribeEvent 'logged-in', @eventToRender
    @subscribeEvent 'log-out', @eventToRender

  attach: ->
    super
    @$('.openClose').showHideDiv()
    $body = $('body')
    for selector in ['#fancybox-overlay', '#fancybox-wrap', '.wbc-propagation-stopper']
      $body.on('click', selector, @stopPropagationHandler)


  stopPropagationHandler: (e) ->
    e.stopPropagation()

  eventToRender: ->
    @render()

  getPromotions : ->
     @model.getPromo(context: @)
       .done(@successPromo)
       .fail(@errorPromo)

  successPromo:(data)->
    @model.set('promo', data.response)

  errorPromo: ->
    @model.set('promo', null)


  render: ()->
    super
    @subview('banner-view', new HeaderBannerView model: @model)