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
  id: "widgetSiteView"
  template: template
  proxyInit: null

  initialize: ->
    super
    @delegate 'click', '#btn-login', @showLoginLayer
    @subscribeEvent 'showHeaderLogin', @showHeaderLogin
    @subscribeEvent 'showHeaderLogout', @showHeaderLogout

  attach: ->
    super
    console.log "WidgetSiteView#attach"
    @proxyInit = new ProxyInit()
    that = this
    @$el.find("#winbits-logout-link").on("click",  (e)->
      that.logout(e)
    )

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
    console.log "WidgetSiteView#showHeaderLogin"
    @$el.find("#headerLogin").show()
    @$el.find("#headerNotLogin").hide()

  showHeaderLogout: () ->
    console.log "WidgetSiteView#showHeaderLogout"
    @$el.find("#headerLogin").hide()
    @$el.find("#headerNotLogin").show()

  logout: (e) ->
    e.preventDefault()
    e.stopPropagation()
    console.log "logout"
    @publishEvent "initLogout"




