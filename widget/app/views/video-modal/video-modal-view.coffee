'use strict'

View = require 'views/base/view'
utils = require 'lib/utils'
cartUtils = require 'lib/cart-utils'
mediator = Winbits.Chaplin.mediator
$ = Winbits.$
_ = Winbits._
env = Winbits.env

module.exports = class LoginView extends View
  container: '#wbi-winbits-modals'
  id: 'wbi-video-modal-view'
  template: require './templates/video-modal'

  initialize: ->
    super

  attach: ->
    super
    @showAsModal()
    video =  @$('#wbi-iframe-video')
    console.log ["video frame ", video]
    video.on('onStateChange',@checkPlayer)

  showAsModal: ->
    $('<a>').wbfancybox(href: '#' + @id, onClosed: (-> utils.redirectTo(controller: 'home', action: 'index')), height:550).click()


  checkPlayer:(state)->
    console.log ["STATE"]
    if state.data is 0
       console.log ["Video end"]
