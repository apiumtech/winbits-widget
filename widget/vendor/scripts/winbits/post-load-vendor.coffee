##
# Post inicialización de las librerías de terceros.
# Aquí hay que poner los noConflict
# User: jluis
# Date: 25/03/14
#
(->
  $.fn.wbfancybox = (options) ->
    defaults = padding: 0, transitionIn: 'none', transitionOut: 'none'
    allOptions = Winbits.$.extend {}, defaults, options
    allOptions.onCleanup = ->
      $ = Winbits.$
      $('div.fancybox-inline-tmp').first().replaceWith $(@href)
      options.onCleanup.apply(@, arguments) if $.isFunction options.onCleanup
    @fancybox allOptions

  $.validator.addMethod("zipCodeDoesNotExist", (value, element) ->
    $element = Winbits.$(element)
    data = $element.data('_zip-code-not-found-error')
    data isnt yes
  ,"El código postal no existe.")

  $.validator.addMethod("wbiPhone", (value) ->
    if value
      /^[0-9]{10,15}/.test value
    else
      yes
  ,"Ingresa un número telefónico valido")

  $.validator.addMethod("wbiSelectInfo", (value, element) ->
    $zipCode = Winbits.$(element).parent().parent().find('input[name=zipCode]')
    if($zipCode.val())
      value.length >= 1
    else
      yes
  ,"Selecccione una opción valida")

  $.validator.addMethod("wbiLocation", (value, element) ->
    $element = Winbits.$(element)
    if $element.is(':visible')
      if !$element.val() then no else yes
    else
      yes
  ,"Campo es requerido.")

  $.fn.wbDate = ()->
    $this = Winbits.$(this)
    day = $this.find('#wbi-birthdate-day').val()
    day = '0' + day if day and day.length == 1
    month = $this.find('#wbi-birthdate-month').val()
    month = '0' + month if month and month.length == 1
    year = '19' + $this.find('#wbi-birthdate-year').val()
    "#{year}-#{month}-#{day}"

  $.validator.addMethod 'validateDate', (value, element)->
    val = Winbits.$(element).parent().wbDate()
    if val and val.length == 10
      moment(val, 'YYYY-MM-DD').isValid()
    else if val.length == 4
      true
    else
      false
  , "Ingresa una fecha valida"

  moment.tz.add
    zones:
      "America/Mexico_City": [
        "-6:36:36 - LMT 1922_0_1_0_23_24 -6:36:36",
        "-7 - MST 1927_5_10_23 -7",
        "-6 - CST 1930_10_15 -6",
        "-7 - MST 1931_4_1_23 -7",
        "-6 - CST 1931_9 -6",
        "-7 - MST 1932_3_1 -7",
        "-6 Mexico C%sT 2001_8_30_02 -5",
        "-6 - CST 2002_1_20 -6",
        "-6 Mexico C%sT"
      ]
    rules:
      Mexico: [
        "1939 1939 1 5 7 0 0 1 D",
        "1939 1939 5 25 7 0 0 0 S",
        "1940 1940 11 9 7 0 0 1 D",
        "1941 1941 3 1 7 0 0 0 S",
        "1943 1943 11 16 7 0 0 1 W",
        "1944 1944 4 1 7 0 0 0 S",
        "1950 1950 1 12 7 0 0 1 D",
        "1950 1950 6 30 7 0 0 0 S",
        "1996 2000 3 1 0 2 0 1 D",
        "1996 2000 9 0 8 2 0 0 S",
        "2001 2001 4 1 0 2 0 1 D",
        "2001 2001 8 0 8 2 0 0 S",
        "2002 9999 3 1 0 2 0 1 D",
        "2002 9999 9 0 8 2 0 0 S"
      ]
    links: {}
  moment().tz("America/Mexico_City").format()

  Winbits.$ = $.noConflict(true)
  Winbits._ = _.noConflict()
  Backbone.$ = Winbits.$
  Winbits.Backbone = Backbone.noConflict()
  Winbits.easyXDM = easyXDM.noConflict('Winbits')
  Winbits.moment = window.moment
  Winbits.Chaplin = window.Chaplin
  Winbits.Handlebars = window.Handlebars
  Winbits.Modernizr = window.Modernizr
  Winbits.html5 = window.html5
  Winbits.require = window.require

  Winbits.$.when.apply(Winbits.$, Winbits.promises).done ->
    delete Winbits.env.set

    Winbits.require 'initialize'
    widgetLoadTime = new Date().getTime() - Winbits.startTime
    console.log ['WIDGET TOTAL LOAD TIME (ms)', widgetLoadTime]
    Winbits.trigger 'initialized'
  .fail ->
    delete Winbits
    alert('Unable to load Winbits Widget!')

  delete Winbits.promises
)()
