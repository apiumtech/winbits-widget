module.exports = (app) ->
  app.initLightbox = ($) ->
    app.$widgetContainer.find("a.fancybox").fancybox
      overlayShow: true
      hideOnOverlayClick: true
      enableEscapeButton: true
      showCloseButton: true
      overlayOpacity: 0.9
      overlayColor: "#333"
      padding: 0
      type: "inline"
      onComplete: ->
        $layer = $(@href)
        $layer.find("form").first().find("input.default").focus()
        $fbHolder = $layer.find(".facebook-btn-holder")
        if $fbHolder.length > 0
          $fbIFrameHolder = app.$widgetContainer.find("#winbits-iframe-holder")
          offset = $fbHolder.offset()
          offset.top = offset.top + 20
          $fbIFrameHolder.offset(offset).height($fbHolder.height()).width($fbHolder.width()).css "z-index", 10000

      onCleanup: ->
        $(@href).find("form").each (i, form) ->
          $form = $(form)
          $form.find(".errors").html ""
          $form.validate().resetForm()
          form.reset()

        $fbIFrameHolder = app.$widgetContainer.find("#winbits-iframe-holder")
        $fbIFrameHolder.offset top: -1000
