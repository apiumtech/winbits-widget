'use strict'

View = require 'views/base/view'
utils = require 'lib/utils'
LoginUtils = require 'lib/login-utils'
ModelMyAccount = require 'models/my-account/my-account'
mediator = Winbits.Chaplin.mediator
$ = Winbits.$
$ = Winbits.$
_ = Winbits._
env = Winbits.env

module.exports = class PromoModalView extends View
  container: '#wbi-winbits-modals'
  id: 'wbi-promo-modal-view'
  template: require './templates/promo-modal'
  model: new ModelMyAccount

  initialize: ->
    super

  attach: ->
    super
    @delegate 'click', '#wbi-promo-modal-link', @newsletterBebitos
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

  newsletterBebitos:(e)->
    e.preventDefault()
    if(utils.isLoggedIn())
      @model.requestLogout()
        .done(@doLogoutSuccess)
        .fail(@doLogoutError)
        .always(@redirectToBebitos)
    else
      @redirectToBebitos()

  doLogoutSuccess: (data) ->
      LoginUtils.doLogoutSuccess(data)

  doLogoutError: (xhr)->
      LoginUtils.doLogoutError(xhr)

  redirectToBebitos:()->
    bebitosUtms=env.get('bebitos-url')+"?utm_medium=Popup&utm_campaign=AltanewsBebitos#wb-login"
    window.location.href=bebitosUtms
