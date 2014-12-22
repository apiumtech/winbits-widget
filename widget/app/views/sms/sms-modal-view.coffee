'use strict'

View = require 'views/base/view'
utils = require 'lib/utils'

module.exports = class SmsModalView extends View
  container: '#wbi-winbits-modals'
  id: 'wbi-sms-activation-modal'
  template: './templates/sms-activation-modal'

  initialize: ->
    super

  attach: ->
    super
    @showAsModal()

  showAsModal: ->
    $('<a>').wbfancybox(href: '#wbi-register-modal', onClosed: -> utils.redirectTo controller: 'home', action: 'index').click()