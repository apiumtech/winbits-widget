'use strict'

View = require 'views/base/view'
utils = require 'lib/utils'
LoginUtils = require 'lib/login-utils'
mediator = Winbits.Chaplin.mediator
$ = Winbits.$
$ = Winbits.$
_ = Winbits._
env = Winbits.env

module.exports = class PromoModalView extends View
  container: '#wbi-winbits-modals'
  id: 'wbi-promo-modal-view'
  template: require './templates/promo-modal'

  initialize: ->
    super

  attach: ->
    super
    @showAsModal()

  showAsModal: ->
    $('<a>').wbfancybox(
      href: '#' + @id
      onClosed: (-> utils.redirectTo(controller: 'home', action: 'index'))
      width:759
      autoSize:no
      transitionIn: 'fadeIn'
      transitionOut: 'fadeOut'
    ).click()

