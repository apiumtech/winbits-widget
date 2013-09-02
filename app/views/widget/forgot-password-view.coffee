template = require 'views/templates/widget/forgot-password'
View = require 'views/base/view'
config = require 'config'
util = require 'lib/util'

module.exports = class ForgotPasswordView extends View
  autoRender: yes
  container: '#forgot-password-modal-body'
  template: template

  render: ->
    super

  initialize: ->
    super

    ###
  attach: ()->
    super
    @$el.find("#recuperaPsw").valid()
     ###
