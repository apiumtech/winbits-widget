module.exports =
    #app.$ = (element) ->
      #(if element instanceof app.jQuery then element else app.jQuery(element))
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


  openFolder : (options) ->
    if @$(options.obj).length
      that = @
      @$(options.trigger).click ->
        that.$(options.obj).slideUp()
        that.$(options.objetivo).slideDown()

  dropMenu : (options) ->
    if @$(options.obj).length
      that = @
      @$(options.trigger).click ->
        that.$(options.other).slideUp()
        that.$(options.obj).slideDown()

      @$(options.obj).each ->
        #console.log $(this)
        that.$(this).bind
          click: (e) ->
            e.stopPropagation()

          mouseenter: ->
           that.$(this).slideDown()

          mouseleave: ->
            that.$(document).click ->
              that.$(options.obj).slideUp()
              that.$(document).unbind "click"
    # +++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      #      CUSTOMSTEPPER: Sumar y restar valores del stepper
      # +++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  customStepper : (obj) ->
    $obj = @$(obj)
    that = @
    if $obj.length
      $obj.each ->
        that.$(this).wrap "<div class=\"stepper\"/>"
        $this = that.$(this).parent()
        $this.append "<span class=\"icon plus\"/><span class=\"icon minus\"/>"
        $this.find(".icon").click ->
          $newVal = undefined
          $button = that.$(this)
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
          that.$(this).val($newVal).trigger "step", $oldValue  if $newVal >= 1
    obj

  resetComponents  : ()->
    @$.find(".reseteable").each((i, reseteable) ->
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
  customCheckbox : (obj) ->
    if @$(obj).length
      that = @
      @$(obj).each ->
        $this = that.$(this)
        $clase = undefined
        if $this.prop("checked")
          $clase = "selectCheckbox"
        else
          $clase = "unselectCheckbox"
        that.$(this).next().andSelf().wrapAll "<div class=\"divCheckbox\"/>"
        $this.parent().prepend "<span class=\"icon spanCheckbox " + $clase + "\"/>"
        $this.parent().find(".spanCheckbox").click ->
          if $this.attr("checked")
            that.$(this).removeClass "selectCheckbox"
            that.$(this).addClass "unselectCheckbox"
            $this.attr "checked", false
          else
            that.$(this).removeClass "unselectCheckbox"
            that.$(this).addClass "selectCheckbox"
            $this.attr "checked", true


  # +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  #      CUSTOMRADIO: Cambiar radio buttons por input text para el género
  # +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  customRadio: (obj) ->
    console.log @$
    that = @
    if @$(obj).length
      @$(obj).find("input[type=\"radio\"]").each ->
        $this = that.$(this)
        $this.wrap "<div class=\"divRadio\"/>"
        $this.parent().append "<span class=\"spanRadio\">" + that.$(this).val() + "</span>"
        $this.parent().find(".spanRadio").click ->
          if $this.prop("checked")
            that.uncheckRadio obj
          else
            that.uncheckRadio obj
            $this.attr "checked", true
            that.$(this).addClass "spanSelected"



  uncheckRadio: (obj) ->
    that=@
    $radio = @$(obj).find("input[type=\"radio\"]")
    $radio.each ->
      that.$(this).attr "checked", false
      that.$(this).parent().find(".spanRadio").removeClass "spanSelected"


 # +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  #      CUSTOMSLIDER: Deslizar el rango para cambiar valor de bits
  # +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  customSlider: (obj) ->
    if @$(obj).length
      that = @
      @$(obj).each ->
        $this = that.$(this)
        $this.wrap "<div class=\"slider\"><div class=\"slider-holder\"/>"
        $this.parent().append "<a href=\"#\" class=\"ui-slider-handle\"><span class=\"bit\"></span><span class=\"amount\">$<em>" + $this.val() + "</em></span></a>"
        $this.parent().parent().append "<span class=\"text-value min-val\">" + $this.data("min") + "</span><span class=\"text-value max-val\">" + $this.data("max") + "</span>"
        $this.parent().parent().find(".slider-holder").slider
          range: "min"
          value: +$this.val()
          min: +$this.data("min")
          max: +$this.data("max")
          slide: (event, ui) ->
            $this.val ui.value
            $this.parent().find(".amount em").text ui.value

          step: $this.data("step")



  # +++++++++++++++++++++++++++++++++++++++++++
  #      CUSTOMSELECT: Customizar el select
  # +++++++++++++++++++++++++++++++++++++++++++
  customSelect: (obj) ->
    $ = @$
    if $(obj).length
      $(obj).each ->
        $this = $(this)
        numberOfOptions = $(this).children("option").length
        selectContent = undefined
        $this.addClass "selectHidden"
        $this.wrap "<div class=\"selectContainer\"/>"
        $this.parent().addClass $this.data("clase")  if $this.data("clase")
        if $this.data("inputselect")
          selectContent = "<input type=\"text\" class=\"selectContent\">"
        else
          selectContent = "<span class=\"selectContent\"/>"
        $this.after selectContent + "<span class=\"icon selectTrigger\"/>"
        $styledSelect = $this.next(".selectContent")
        if $this.data("inputselect")
          $styledSelect.attr("placeholder", $this.children("option").eq(0).text()).addClass $this.children("option").eq(0).data("icon")
        else
          $styledSelect.text($this.children("option").eq(0).text()).addClass $this.children("option").eq(0).data("icon")
        $list = $("<ul />",
          class: "selectOptions"
        ).insertAfter($this.parent().find("span.selectTrigger"))
        i = 0

        while i < numberOfOptions
          $("<li />",
            text: $this.children("option").eq(i).text()
            rel: $this.children("option").eq(i).val()
            "data-class": $this.children("option").eq(i).data("icon")
          ).appendTo $list
          i++
        $listItems = $list.children("li")
        $this.parent().find("span.selectTrigger").click (e) ->
          e.stopPropagation()
          $("div.styledSelect.active").each ->
            $(this).removeClass("active").next("ul.selectOptions").hide()

          $(this).toggleClass("active").next("ul.selectOptions").toggle()

        $listItems.click (e) ->
          e.stopPropagation()
          if $this.data("inputselect")
            $styledSelect.val($(this).text()).removeClass("active").removeClass().addClass "selectActive selectContent " + $(this).data("class")
          else
            $styledSelect.text($(this).text()).removeClass("active").removeClass().addClass "selectActive selectContent " + $(this).data("class")
          $this.val $(this).attr("rel")
          $list.hide()

        $(document).click ->
          $styledSelect.removeClass "active"
          $list.hide()

