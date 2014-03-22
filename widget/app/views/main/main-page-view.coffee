View = require 'views/base/view'

module.exports = class MainPageView extends View
  container: 'main'
  className: 'wb-main'
  template: require './templates/main'
  autoAttach: true

