'use strict'

View = require 'views/base/view'
utils = require 'lib/utils'
mediator = Winbits.Chaplin.mediator
$ = Winbits.$
env = Winbits.env

module.exports = class MyProfileView extends View
  container: '.wbc-my-account-container'
  id: 'wbi-my-profile'
  template: require './templates/my-profile'

  initialize: ->
    super
    @listenTo @model, 'change', @render

  attach: ->
    super
    @$('[name=zipCodeInfo]').wblocationselect()
    @$('.divGender').customRadio()
    @$('.requiredField').requiredField()
