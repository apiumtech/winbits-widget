HeaderView = require 'views/header/header-view'

describe 'HeaderView', ->
  beforeEach ->
    @view = new HeaderView

  afterEach ->
    @view.dispose()

  it 'check rendered', ->
    expect(@view.$ '.widgetWinbitsHeader').is.rendered
