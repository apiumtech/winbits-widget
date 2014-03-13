View = require 'views/base/view'
Routes = require 'routes'

module.exports = class HeaderPageView extends View
  container: 'header'
  autoRender:true
  className: 'wb-header'
  template: require './templates/header'
  autoAttach: true

