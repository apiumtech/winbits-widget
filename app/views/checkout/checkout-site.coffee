View = require 'views/base/view'
template = require 'views/templates/checkout/checkout-site'
util = require 'lib/util'
config = require 'config'
ProxyInit = require 'lib/proxyInit'

# Site view is a top-level view which is bound to body.
module.exports = class CheckoutSiteView extends View
  container: 'body'
  autoRender: yes
  #regions:
  #'#header-container': 'header'
  #'#page-container': 'main'
  id: "checkoutSiteView"
  template: template
  proxyInit: null

  initialize: ->
    super
  attach: ->
    super
