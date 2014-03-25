require 'lib/view-helper' # Just load the view helpers, no return value

module.exports = class View extends Chaplin.View
  # Auto-save `template` option passed to any view as `@template`.
  optionNames: Chaplin.View::optionNames.concat ['template']

  # Precompiled templates function initializer.
  getTemplateFunction: ->
    template = @template

    if typeof template is 'string'
      # Compile the template string to a function and save it
      # on the prototype. This is a workaround since an instance
      # shouldn’t change its prototype normally.
      templateFunc = Handlebars.compile template
      @constructor::template = templateFunc
    else
      templateFunc = template

    templateFunc

  render: ->
      # Do not render if the object was disposed
      # (render might be called as an event handler which wasn’t
      # removed correctly).
      return false if @disposed

      templateFunc = @getTemplateFunction()

      if typeof templateFunc is 'function'
        # Call the template function passing the template data.
        html = templateFunc @getTemplateData()

        # Replace HTML
        @$el.html html

      # Return the view.
      this

  # This method is called after a specific `render` of a derived class.

  Handlebars.registerHelper "debug", (optionalValue) ->
    console.log "Current Context"
    console.log "===================="
    console.log ['debug context0:', this]
    if optionalValue
      console.log "Value"
      console.log "===================="
      console.log optionalValue
