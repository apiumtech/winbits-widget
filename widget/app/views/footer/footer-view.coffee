View = require 'views/base/view'

module.exports = class FooterView extends View
  container: 'footer'
  template: require './templates/footer'
  noWrap: true
