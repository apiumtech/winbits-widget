util = {}
  #app.$ = (element) ->
    #(if element instanceof app.jQuery then element else app.jQuery(element))

util.setCookie = setCookie = (c_name, value, exdays) ->
  exdays = exdays or 7
  exdate = new Date()
  exdate.setDate exdate.getDate() + exdays
  c_value = escape(value) + ((if (exdays is null) then "" else "; path=/; expires=" + exdate.toUTCString()))
  document.cookie = c_name + "=" + c_value

util.getCookie = getCookie = (c_name) ->
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

util.deleteCookie = (name) ->
  document.cookie = name + "=; path=/; expires=Thu, 01 Jan 1970 00:00:01 GMT"

util.getUrlParams = ->
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

util.validateForm = (form) ->
  $form = $(form)
  $form.find(".errors").html ""
  $form.valid()


util.alertErrors = ($) ->
  params = util.getUrlParams()
  alert params._wb_error  if params._wb_error


util.Forms = util.Forms or {}
util.Forms.serializeForm = ($, form, context) ->
  formData = context or {}
  $form = $(form)
  $.each $form.serializeArray(), (i, f) ->
    formData[f.name] = f.value

  formData


util.openFolder = (options) ->
  if $(options.obj).length
    $(options.trigger).click ->
      $(options.obj).slideUp()
      $(options.objetivo).slideDown()

util.dropMenu = (options) ->
  #console.log options.obj
  #console.log "-'- ---->"
  #console.log $(options.obj)
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
util.customStepper = (obj) ->
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


module.exports =  util
