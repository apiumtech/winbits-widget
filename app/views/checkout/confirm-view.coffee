View = require 'views/base/view'
template = require 'views/templates/checkout/confirm'
util = require 'lib/util'
config = require 'config'
mediator = require 'chaplin/mediator'

# Site view is a top-level view which is bound to body.
module.exports = class ConfirmView extends View
  container: '.checkoutSummaryContainer'
  autoRender: yes
  #regions:
  #'#header-container': 'header'
  #'#page-container': 'main'
  template: template

  initialize: ->
    super

  attach: ->
    super
    $form = @$("#paypalForm")
    if $form
      $form.submit()

