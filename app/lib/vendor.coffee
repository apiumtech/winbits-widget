ChaplinMediator = require 'chaplin/mediator'
module.exports =

# +++++++++++++++++++++++++++++++++++++++++++++
#      ACCORDEON: Acordeón para el historial
# +++++++++++++++++++++++++++++++++++++++++++++
  accordeon : (options) ->
    $ = window.Winbits.$ # NO BORRAR - Fix desarrollo
    if $(options.obj).length
      if options.first
        $(options.obj).find(options.trigger).first().addClass(options.claseActivo).find(".icon").toggleClass options.minusIcon
        $(options.obj).find(options.contenedor).not(":first").hide()
      else
        $(options.obj).find(options.contenedor).hide()
      $(options.obj).find(options.trigger).click ->
        $(this).next(options.contenedor).slideToggle() #.siblings(options.contenedor+':visible').slideUp()
        $(this).toggleClass(options.claseActivo).find(".icon").toggleClass options.minusIcon
#        $(this).siblings(options.trigger).removeClass(options.claseActivo).find(".icon").removeClass options.minusIcon
        event = if $(this).is('.' + options.claseActivo) then 'expanded' else 'collapsed'
        $(options.obj).trigger event, [$(this)]


  # ++++++++++++++++++++++++++++++++
  #      ADDEVENT: Atachar evento
  # ++++++++++++++++++++++++++++++++
  addEvent : (obj, type, fn) ->
    if obj.addEventListener
      obj.addEventListener type, fn, false
    else if obj.attachEvent
      obj["e" + type + fn] = fn
      obj[type + fn] = ->
        obj["e" + type + fn] window.event

      obj.attachEvent "on" + type, obj[type + fn]


  # +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  #      CHANGEBOX: Cambiar div para seleccionar direccion/tarjeta
  # +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  changeBox : (options) ->
    $ = Winbits.$ # NO BORRAR - Fix desarrollo
    if $(options.obj).length
      $(options.objetivo).each ->
        $this = $(this)
        $this.click ->
          quitaClase
            obj: options.objetivo
            clase: options.activo

          uncheck options.inputradio
          $this.addClass options.activo
          $this.find("input").attr "checked", true




  # +++++++++++++++++++++++++++++++++++++++++
  #      CUSTOMCHECKBOX: Cambiar checkbox
  # +++++++++++++++++++++++++++++++++++++++++
  customCheckbox : (obj) ->
    $ = Winbits.$ # NO BORRAR - Fix desarrollo
    if $(obj).length
      $(obj).each ->
        $this = $(this)
        $clase = `undefined`
        if $this.prop("checked")
          $clase = "selectCheckbox"
        else
          $clase = "unselectCheckbox"
        $(this).next().andSelf().wrapAll "<div class=\"divCheckbox\"/>"
        $this.parent().prepend "<span class=\"icon spanCheckbox " + $clase + "\"/>"
        $this.parent().find(".spanCheckbox").click ->
          if $this.prop("checked")
            $(this).removeClass "selectCheckbox"
            $(this).addClass "unselectCheckbox"
            $this.attr "checked", false
          else
            $(this).removeClass "unselectCheckbox"
            $(this).addClass "selectCheckbox"
            $this.attr "checked", true




# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#      CUSTOMRADIO: Cambiar radio buttons por input text para el género
# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  customRadio: (obj) ->
    $ = Winbits.$ # NO BORRAR - Fix desarrollo
    that = @ # NO BORRAR - Fix desarrollo
    if $(obj).length
      $(obj).find("input[type=\"radio\"]").each ->
        $this = $(this)
        $this.wrap "<div class=\"divRadio\"/>"
        $this.parent().append "<span class=\"spanRadio\">" + $(this).val() + "</span>"
        $this.parent().find(".spanRadio").click ->
          if $this.prop("checked")
            that.uncheckRadio obj
          else
            that.uncheckRadio obj
            $this.attr "checked", true
            $(this).addClass "spanSelected"



  uncheckRadio: (obj) ->
    $ = Winbits.$ # NO BORRAR - Fix desarrollo
    $radio = $(obj).find("input[type=\"radio\"]")
    $radio.each ->
      $(this).attr "checked", false
      $(this).parent().find(".spanRadio").removeClass "spanSelected"



# +++++++++++++++++++++++++++++++++++++++++++
#      CUSTOMSELECT: Customizar el select
# +++++++++++++++++++++++++++++++++++++++++++
  customSelect: (obj) ->
    $ = Winbits.$ # NO BORRAR - Fix desarrollo
    $obj = $(obj)
    if $obj.length
      $obj.each ->
        $this = $(this).wrap('<div class="selectContainer"/>').addClass "selectHidden"
        $parent = $this.parent()
        $parent.addClass($this.data("clase")) if $this.data("clase")
        $firstOption = $this.children().first()
        $styledSelect = $('<span class="selectContent selectActive"/>').text($firstOption.text()).addClass($firstOption.data("icon")).appendTo $parent
        $('<span class="icon selectTrigger"/>').appendTo($parent).click (e) ->
          e.stopPropagation()
          $trigger = $(this)
          $selectContent = $trigger.prev()
          $("span.selectContent.active").not($selectContent).each ->
            $(this).removeClass("active").nextAll("ul.selectOptions").hide()
          $selectContent.toggleClass("active")
          $trigger.next("ul.selectOptions").toggle()

        $list = $("<ul />", class: "selectOptions").appendTo($parent)

        $this.children().each (i, option) ->
          $option = $(option)
          $li = $("<li />",
            text: $option.text()
            rel: $option.val()
            "data-class": $option.data("icon")
          ).appendTo($list).click (e) ->
            e.stopPropagation()
            $liOption = $(this)
            $selectContainer = $liOption.closest('.selectContainer')
            $selectContainer.children('.selectContent').text($liOption.text()).removeClass("active").addClass $liOption.data("class")
            $select = $selectContainer.children('select')
            selectedValue = $liOption.attr("rel")
            if $select.val() != selectedValue
              $select.val(selectedValue).change()
            $liOption.parent().hide()
          if $option.attr('selected')
            $styledSelect.text($li.text()).removeClass("active").addClass $li.data("class")
        $(document).click ->
          $styledSelect.removeClass "active"
          $list.hide()
    $obj

  # +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  #      CUSTOMSLIDER: Deslizar el rango para cambiar valor de bits
  # +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  customSlider: (obj) ->
    $slider = Winbits.$()
    $ = Winbits.$ # NO BORRAR - Fix desarrollo
    if $(obj).length
      $(obj).each ->
        $this = $(this)
        $this.wrap "<div class=\"slider\"><div class=\"slider-holder\"/>"
        $this.parent().append "<a href=\"#\" class=\"ui-slider-handle\"><span class=\"bit\"></span><span class=\"amount\">$<em>" + $this.val() + "</em></span></a>"
        $this.parent().parent().append "<span class=\"text-value min-val\">" + $this.data("min") + "</span><span class=\"text-value max-val\">" + $this.data("max") + "</span>"
        $slider = $this.parent().parent().find(".slider-holder").slider # NO BORRAR - Fix desarrollo
          range: "min"
          value: +$this.val()
          min: +$this.data("min")
          max: +$this.data("max")
          slide: (event, ui) ->
            maxSelection = parseInt($this.data('max-selection') or '0')
            value = Math.min(maxSelection, ui.value)
            previousValue = $this.val()
            $this.val value
            $this.parent().find(".amount em").text value

            if ui.value > maxSelection
              if previousValue != maxSelection
                $(@).slider('value', maxSelection)
              false
          step: $this.data("step")
    $slider # NO BORRAR - Fix desarrollo




  # +++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  #      CUSTOMSTEPPER: Sumar y restar valores del stepper
  # +++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  customStepper : (obj) ->
    $ = Winbits.$ # NO BORRAR - Fix desarrollo
    if $(obj).length
      $(obj).each ->
        $(this).wrap "<div class=\"stepper\"/>"
        $this = $(this).parent()
        $this.append "<span class=\"icon plus\"/><span class=\"icon minus\"/>"
        $this.find(".icon").click ->
          $newVal = `undefined`
          $button = $(this)
          $oldValue = parseInt($button.parent().find("input").val(), 10)
          if $button.hasClass("plus")
            $newVal = $oldValue + 1
          else if $button.hasClass("minus")
            if $oldValue >= 2
              $newVal = $oldValue - 1
            else
              $newVal = 1
          $currentInput = $button.parent().find("input")
          $currentInput.val($newVal).trigger "step", $oldValue # NO BORRAR - Fix desarrollo
          $currentInput.trigger "change" # NO BORRAR - Fix desarrollo

        $this.find("input").keydown (e) ->
          keyCode = e.keyCode or e.which
          arrow =
            up: 38
            down: 40

          $newVal = `undefined`
          $oldValue = parseInt($(this).val(), 10)
          switch keyCode
            when arrow.up
              $newVal = $oldValue + 1
            when arrow.down
              $newVal = $oldValue - 1
          $(this).val($newVal).trigger "step", $oldValue  if $newVal >= 1 # NO BORRAR - Fix desarrollo
          $(this).trigger "change" # NO BORRAR - Fix desarrollo
    $(obj) # NO BORRAR - Fix desarrollo




  # +++++++++++++++++++++++++++++++++++
  #      DROPMENU: Abrir los menús
  # +++++++++++++++++++++++++++++++++++
  dropMenu : (options) ->
    $ = Winbits.$ # NO BORRAR - Fix desarrollo
    if $(options.obj).length
      $(options.trigger).click (e) ->
        e.stopPropagation()
        $possibleCartCounter = $(e.currentTarget).prev()
        if $possibleCartCounter.hasClass('cart-items-count') and $possibleCartCounter.text().trim() is '0'
          return
        $(options.other).slideUp()
        $(options.obj).slideDown()

      $(options.obj).each ->
        $objeto = `undefined`
        if options.carro is true
          $objeto = $(this).find(".wrapper").children().eq(0)
        else
          $objeto = $(this).find(".wrapper")

        $objeto.bind
          click: (e) ->
            e.stopPropagation()

          mouseenter: (e) ->
            $(this).slideDown()

          mouseleave: ->
            $(document).click ->
              $(options.obj).slideUp()
              $(document).unbind "click"

  # +++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  #      OPENFOLDER: Abrir el DIV superior del encabezado
  # +++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  openFolder : (options) ->
    $ = Winbits.$ # NO BORRAR - Fix desarrollo
    if $(options.obj).length
      $(options.trigger).click ->
        $(options.obj).slideUp()
        $(options.objetivo).slideDown()



  # +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  #      QUITACLASE: Remover todas las clases con una iteración
  # +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  quitaClase : (options) ->
    $ = Winbits.$ # NO BORRAR - Fix desarrollo
    $(options.obj).each ->
      $(this).removeClass options.clase



  # +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  #      SCROLLPANE: Scroll que aparece / desaparece
  # +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  scrollpane : (obj, father) ->
    $ = Winbits.$ # NO BORRAR - Fix desarrollo
    if father
      # NO BORRAR - Fix desarrollo las siguientes 7 líneas
      display = $(father).css("display")
      if display is "none"
        $(father).css "display", "block"
      $(obj).jScrollPane
        horizontalDragMinWidth: 40
        horizontalDragMaxWidth: 40

      $(father).css "display", display



  # +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  #      STICKYFOOTER: Pegar el footer sin importar el tamaño de la página
  # +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  stickyFooter : (obj) ->
    $ = Winbits.$ # NO BORRAR - Fix desarrollo
    unless $(".bodyModal").length
      footerHeight = 0
      footerTop = 0
      $footer = $(obj)
      $footer.css "position", "static"
      footerHeight = parseInt($footer.height(), 10) + parseInt($footer.css("padding-top"), 10) + parseInt($footer.css("padding-bottom"), 10)
      footerTop = ($(window).scrollTop() + $(window).height() - footerHeight) + "px"
      if ($(document.body).height()) < $(window).height()
        $footer.css
          position: "absolute"
          bottom: 0
          width: "100%"

      else
        $footer.css "position", "static"


  # +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  #      UNCHECK: Iterar para remover el checked en radiobutton y checkbox
  # +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  uncheck : (obj) ->
    $ = Winbits.$ # NO BORRAR - Fix desarrollo
    $(obj).each ->
      $(this).attr "checked", false



  # +++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  #      VALIDAR: Validar formularios
  # +++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  validar : (obj) ->
    $ = Winbits.$ # NO BORRAR - Fix desarrollo
    $.extend $.validator.messages,
      required: "Campo requerido."
      remote: "Llena este campo."
      email: "Escribe una dirección de correo válida"
      url: "Escribe una URL válida."
      date: "Escribe una fecha válida."
      dateISO: "Escribe una fecha (ISO) válida."
      number: "Escribe un número entero válido."
      digits: "Escribe sólo dígitos."
      creditcard: "Escribe un número de tarjeta válido."
      equalTo: "Escribe el mismo valor de nuevo."
      accept: "Escribe un valor con una extensión aceptada."
      maxlength: jQuery.validator.format("No escribas más de {0} caracteres.")
      minlength: jQuery.validator.format("No escribas menos de {0} caracteres.")
      rangelength: jQuery.validator.format("Escribe un valor entre {0} y {1} caracteres.")
      range: jQuery.validator.format("Escribe un valor entre {0} y {1}.")
      max: jQuery.validator.format("Escribe un valor menor o igual a {0}.")
      min: jQuery.validator.format("Escribe un valor mayor o igual a {0}.")

    if $(obj.container).length
      $(obj.form).validate
        errorClass: "errorInputError"
        errorElement: "span"
        onfocusout: (element) ->
          $(element).valid()

        success: (label) ->
          label.addClass "errorInputOK"

        rules: obj.rules
        validClass: "errorInputOK"

