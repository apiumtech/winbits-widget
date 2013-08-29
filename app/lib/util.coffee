vendor = require 'lib/vendor'

module.exports =
  $ : window.w$
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

  resetComponents  : ()->
    $elements =  @$.find(".reseteable")
    that = @
    that.$($elements).each((i, reseteable) ->
        $reseteable = that.$(reseteable)
        if $reseteable.is("[data-reset-val]")
          $reseteable.val $reseteable.attr("data-reset-val")
        else if $reseteable.is("[data-reset-text]")
          $reseteable.text $reseteable.attr("data-reset-text")
        else if $reseteable.is("[data-reset-unload]")
          $reseteable.html ""
        else
          $reseteable.val ""
      )

  calculateOrderFullPrice: (details) ->
    orderFullPrice = 0.0
    w$.each details, (index, detail) ->
      orderFullPrice += detail.sku.fullPrice * detail.quantity
    orderFullPrice

  backToSite: (e) ->
    $ = Backbone.$
    $main = $('main').first()
    $main.find('div.wrapper').show()
    $main.find('div.wrapper.subview').hide()

  resetLocationSelect: ($select) ->
    $select.html '<option>Localidad</option>'
    $select.parent().find('ul').html '<li rel="Localidad">Localidad</li>'
