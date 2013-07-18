View = require 'views/base/view'
template = require 'views/templates/checkout/payment-methods'
util = require 'lib/util'
config = require 'config'

# Site view is a top-level view which is bound to body.
module.exports = class PaymentView extends View
  container: '.checkoutPaymentContainer'
  autoRender: yes
  #regions:
  #'#header-container': 'header'
  #'#page-container': 'main'
  template: template

  initialize: ->
    super
  attach: ->
    super
    console.log "CheckoutSiteView#attach"
