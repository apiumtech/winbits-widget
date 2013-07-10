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
    @delegate 'click', '.close-icon', @closeModal
    @delegate 'click', 'i.close-icon', @closeModal
    @delegate 'click', '#registerLink', @viewRegister
    @delegate 'click', '#viewVideoLink', @viewVideo
    @subscribeEvent 'showHeaderLogin', @showHeaderLogin
    @subscribeEvent 'showHeaderLogout', @showHeaderLogout
    @subscribeEvent 'resetComponents', @resetComponents
    @subscribeEvent 'updateCartCounter', @updateCartCounter
    @subscribeEvent 'showConfirmation', @showConfirmation

  updateCartCounter: (count)->
    console.log ["WidgetSiteView#updateCartCounter " + count]
    @$el.find(".cart-items-count").html(count)

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

  viewRegister: (e)->
    e.preventDefault()
    console.log "WidgetSiteView#viewRegister"
    #console.log $("#login-layer")
    maxHeight = $(window).height() - 200
    $("#register-modal .modal-body").css("max-height", maxHeight)
    $("#register-modal").modal( 'show' ).css {
      'background-color': 'transparent',
      float: 'left',
      width: '534px',
      'margin-left': -> -( $( this ).width() / 2 )
      top: '50%',
      'max-height': maxHeight,
      'margin-top': -> -(  $( this ).height() / 2 )
    }

  viewVideo: (e)->
    e.preventDefault()
    console.log "WidgetSiteView#viewVideo"
    #console.log $("#login-layer")
    maxHeight = $(window).height() - 200
    $("#view-video-modal .modal-body").css("max-height", maxHeight)
    $("#view-video-modal").modal( 'show' ).css {
      'background-color': 'transparent',
      float: 'left',
      width: '560px',
      'margin-left': -> -( $( this ).width() / 2 )
      top: '50%',
      'max-height': maxHeight,
      'margin-top': -> -(  $( this ).height() / 2 )
    }

  closeModal: (event) ->
    event?.preventDefault()
    event?.stopPropagation()
    $('.modal').modal 'hide'

  showConfirmation: () ->
    e.preventDefault()
    console.log "WidgetSiteView#showConfirmation"
    #console.log $("#login-layer")
    maxHeight = $(window).height() - 200
    $("#register-confirmation-modal .modal-body").css("max-height", maxHeight)
    $("#register-confirmation-modal").modal( 'show' ).css {
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

  resetComponents: () ->
    console.log "WidgetSiteView#resetComponents"
    util.resetComponents(@$el)

  logout: (e) ->
    e.preventDefault()
    e.stopPropagation()
    console.log "logout"
    @publishEvent "initLogout"

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


