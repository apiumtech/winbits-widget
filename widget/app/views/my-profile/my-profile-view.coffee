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
    console.log('VALIDATING FORM')
    @$('#wbi-personal-data-form').validate
      rules:
        zipCode: zipCodeDoesNotExist: yes
    @$('[name=zipCodeInfo]').wblocationselect()
    @$('.divGender').customRadio()
    @$('.requiredField').requiredField()
