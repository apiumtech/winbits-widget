module.exports =
    #app.$ = (element) ->
      #(if element instanceof app.jQuery then element else app.jQuery(element))

  setCookie : setCookie = (c_name, value, exdays) ->
    exdays = exdays or 7
    exdate = new Date()
    exdate.setDate exdate.getDate() + exdays
    c_value = escape(value) + ((if (exdays is null) then "" else "; path=/; expires=" + exdate.toUTCString()))
    document.cookie = c_name + "=" + c_value

  getCookie : getCookie = (c_name) ->
    c_value = document.cookie
    c_start = c_value.indexOf(" " + c_name + "=")
    c_start = c_value.indexOf(c_name + "=")  if c_start is -1
    if c_start is -1
      c_value = null
    else
      c_start = c_value.indexOf("=", c_start) + 1
      c_end = c_value.indexOf(";", c_start)
      c_end = c_value.length  if c_end is -1
      c_value = unescape(c_value.substring(c_start, c_end))
    c_value

  deleteCookie : (name) ->
    document.cookie = name + "=; path=/; expires=Thu, 01 Jan 1970 00:00:01 GMT"

  getUrlParams : ->
    vars = []
    hash = undefined
    hashes = window.location.href.slice(window.location.href.indexOf("?") + 1).split("&")
    i = 0

    while i < hashes.length
      hash = hashes[i].split("=")
      vars.push hash[0]
      vars[hash[0]] = hash[1]
      i++
    vars

  validateForm : (form) ->
    $form = Backbone.$(form)
    $form.find(".errors").html ""
    $form.valid()


  alertErrors : ($) ->
    params = util.getUrlParams()
    alert params._wb_error  if params._wb_error


  serializeForm : ($form, context) ->
    formData = context or {}
    Backbone.$.each $form.serializeArray(), (i, f) ->
      formData[f.name] = f.value

    formData


  openFolder : ($, options) ->
    if $(options.obj).length
      $(options.trigger).click ->
        $(options.obj).slideUp()
        $(options.objetivo).slideDown()

  dropMenu : ($, options) ->
    if $(options.obj).length
      #console.log ":P ---->"
      #console.log $(options.trigger)
      $(options.trigger).click ->
        #console.log "fat ---->"
        #console.log $(options.other)
        $(options.other).slideUp()
        $(options.obj).slideDown()

      $(options.obj).each ->
        #console.log $(this)
        $(this).bind
          click: (e) ->
            e.stopPropagation()

          mouseenter: ->
            $(this).slideDown()

          mouseleave: ->
            $(document).click ->
              $(options.obj).slideUp()
              $(document).unbind "click"
    # +++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      #      CUSTOMSTEPPER: Sumar y restar valores del stepper
      # +++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  customStepper : ($, obj) ->
    $obj = $(obj)
    if $obj.length
      $obj.each ->
        $(this).wrap "<div class=\"stepper\"/>"
        $this = $(this).parent()
        $this.append "<span class=\"icon plus\"/><span class=\"icon minus\"/>"
        $this.find(".icon").click ->
          $newVal = undefined
          $button = $(this)
          $oldValue = parseInt($button.parent().find("input").val(), 10)
          if $button.hasClass("plus")
            $newVal = $oldValue + 1
          else if $button.hasClass("minus")
            if $oldValue >= 2
              $newVal = $oldValue - 1
            else
              $newVal = 1
          $button.parent().find("input").val($newVal).trigger "step", $oldValue

        $this.find("input").keydown (e) ->
          keyCode = e.keyCode or e.which
          arrow =
            up: 38
            down: 40

          $newVal = undefined
          $oldValue = parseInt($(this).val(), 10)
          switch keyCode
            when arrow.up
              $newVal = $oldValue + 1
            when arrow.down
              $newVal = $oldValue - 1
          $(this).val($newVal).trigger "step", $oldValue  if $newVal >= 1
    obj

  resetComponents  : ($, $selector)->
    $selector.find(".reseteable").each((i, reseteable) ->
        $reseteable = $(reseteable)
        if $reseteable.is("[data-reset-val]")
          $reseteable.val $reseteable.attr("data-reset-val")
        else if $reseteable.is("[data-reset-text]")
          $reseteable.text $reseteable.attr("data-reset-text")
        else if $reseteable.is("[data-reset-unload]")
          $reseteable.html ""
        else
          $reseteable.val ""
      )


  # +++++++++++++++++++++++++++++++++++++++++
  #      CUSTOMCHECKBOX: Cambiar checkbox
  # +++++++++++++++++++++++++++++++++++++++++
  customCheckbox : ($, obj) ->
    if $(obj).length
      $(obj).each ->
        $this = $(this)
        $clase = undefined
        if $this.prop("checked")
          $clase = "selectCheckbox"
        else
          $clase = "unselectCheckbox"
        $(this).next().andSelf().wrapAll "<div class=\"divCheckbox\"/>"
        $this.parent().prepend "<span class=\"icon spanCheckbox " + $clase + "\"/>"
        $this.parent().find(".spanCheckbox").click ->
          if $this.attr("checked")
            $(this).removeClass "selectCheckbox"
            $(this).addClass "unselectCheckbox"
            $this.attr "checked", false
          else
            $(this).removeClass "unselectCheckbox"
            $(this).addClass "selectCheckbox"
            $this.attr "checked", true
