template = require 'views/templates/widget/profile'
View = require 'views/base/view'
config = require 'config'
util = require 'lib/util'

module.exports = class CompleteRegisterView extends View
  autoRender: yes
  container: '#headerProfile'
  template: template

  initialize: ->
    super
    @subscribeEvent 'completeRegister', @showCompleteRegisterModal

  showCompleteRegisterModal: (cashback) ->
    console.log("COMPLETE REGISTER :" + cashback)
    alert ('¡Felicidades! Has ganado ' + cashback + ' bits por completar tu registro')



