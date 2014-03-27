# Application-specific utilities
# ------------------------------

# Delegate to Chaplin’s utils module.
utils = Chaplin.utils.beget Chaplin.utils
$ = Winbits.$

# _(utils).extend
#  someMethod: ->
Winbits._(utils).extend
  redirectToLoggedInHome: ->
    @redirectTo controller: 'logged-in', action: 'index'

  redirectToNotLoggedInHome: ->
    @redirectTo 'not-logged-in#index'

  serializeForm : ($form, context) ->
    formData = context or {}
    $.each $form.serializeArray(), (i, f) ->
      formData[f.name] = f.value
    formData

  validateForm : (form) ->
    $form = $(form)
    $form.find(".errors").html ""
    $form.valid()

  ajaxRequest:(url, options) ->
    if $.isPlainObject(url)
      options = url
      url = options.url
    options = options or {}
    if ($.browser.msie and not /10.*/.test($.browser.version))
      context = options.context or @
      Winbits.rpc.request(url, options, () ->
        options.success.apply(context, arguments) if $.isFunction options.success
        options.complete.call(context) if $.isFunction options.complete
      , () ->
        options.error.apply(context, arguments) if $.isFunction options.error
        options.complete.call(context) if $.isFunction options.complete
      )
    else
      $.ajax(url,options)

# Prevent creating new properties and stuff.
Object.seal? utils

module.exports = utils
