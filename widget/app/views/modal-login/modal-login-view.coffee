View = require 'views/base/view'
util = require 'lib/util'
config = require 'config'

module.exports = class ModalLoginPageView extends View
  container: 'header'
  id: 'login-modal'
  className: 'hide'
  autoRender: true
  template: require './templates/modal-login'
  autoAttach: true

  initialize: ->
   super

   attach: ->
    super
