ChaplinView = require 'chaplin/views/view'
require 'lib/view-helper' # Just load the view helpers, no return value

module.exports = class View extends ChaplinView
  # Precompiled templates function initializer.
  getTemplateFunction: ->
    console.log ":-|"
    @template
