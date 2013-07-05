View = require 'views/base/view'
template = require 'views/templates/widget-site'
util = require 'lib/util'
ProxyInit = require 'lib/proxyInit'

# Site view is a top-level view which is bound to body.
module.exports = class WidgetSiteView extends View
  container: '#winbits-widget'
  autoRender: yes
  #regions:
  #'#header-container': 'header'
  #'#page-container': 'main'
  template: template
  proxyInit: null

  initialize: ->
    super
    @delegate 'click', '#btn-login', @showLoginLayer
    @delegate 'click', '#winbits-logout-link', @logout
    @subscribeEvent 'showHeaderLogin', @showHeaderLogin


  attach: ->
    super
    console.log "WidgetSiteView#attach"
    @proxyInit = new ProxyInit()
    console.log  $(@.el).find("#winbits-logout-link")
    $(@.el).find("#winbits-logout-link").click ->
      console.log "click logout"
    #@delegate 'click', '#winbits-logout-link', @logout

    util.dropMenu
      obj: ".miCuentaDiv"
      clase: ".dropMenu"
      trigger: ".triggerMiCuenta"
      other: ".miCarritoDiv"

    util.dropMenu
      obj: ".miCarritoDiv"
      clase: ".dropMenu"
      trigger: ".shopCarMin"
      other: ".miCuentaDiv"


    util.openFolder
      obj: ".knowMoreMin"
      trigger: ".knowMoreMin .openClose"
      objetivo: ".knowMoreMax"

    util.openFolder
      obj: ".knowMoreMax"
      trigger: ".knowMoreMax .openClose"
      objetivo: ".knowMoreMin"



  showLoginLayer: (e)->
    e.preventDefault()
    console.log "WidgetSiteView#showLoginLayer"
    #console.log $("#login-layer")


    maxHeight = $(window).height() - 200
    $("#login-modal .modal-body").css("max-height", maxHeight)
    $("#login-modal").modal( 'show' ).css {
      'background-color': 'transparent',
      float: 'left',
      width: '330px',
      'margin-left': -> -( $( this ).width() / 2 )
      top: '50%',
      'max-height': maxHeight,
      'margin-top': -> -(  $( this ).height() / 2 )
    }


  showHeaderLogin: () ->
    console.log "WidgetSiteView#showLoginLayer"
    #console.log @el
    #console.log @.el
    $(@.el).find("#headerLogin").show()
    $(@.el).find("#headerNotLogin").hide()

  logout: (e) ->
    e.preventDefault()
    e.stopPropagation()
    console.log "logout"
    @publishEvent initLogout




