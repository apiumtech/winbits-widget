'use strict'

View = require 'views/base/view'
MyProfile = require 'models/my-profile/my-profile'
utils = require 'lib/utils'
mediator = Winbits.Chaplin.mediator
$ = Winbits.$
env = Winbits.env

module.exports = class MyProfileView extends View
  container: '.wbc-my-account-container'
  id: 'wbi-my-profile'
  template: require './templates/my-profile'
  model: new MyProfile

  initialize: ->
    super
    @listenTo @model, 'change', @render

  attach: ->
    super
    @$('.divGender').customRadio()
