View = require 'views/base/view'
template = require 'views/templates/checkout/checkout-site'
util = require 'lib/util'
config = require 'config'

# Site view is a top-level view which is bound to body.
module.exports = class CheckoutSiteView extends View
  container: 'body'
  autoRender: false
  #regions:
  #'#header-container': 'header'
  #'#page-container': 'main'
  template: template

  initialize: ->
    super
    @subscribeEvent "showStep", @showStep


  showStep: (selector)->
    console.log "---------dssafads"
    console.log @$(".chk-step")
    @$(".chk-step").hide()
    @$(selector).show()

  attach: ->
    super
    console.log "CheckoutSiteView#attach"
