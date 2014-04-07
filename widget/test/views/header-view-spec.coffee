HeaderView = require 'views/header/header-view'

describe 'HeaderViewSpec', ->
  beforeEach ->
    @view = new HeaderView

  afterEach ->
    @view.dispose()

  it 'check is rendered', ->
    expect(@view.$ '.widgetWinbitsHeader').to.exist
