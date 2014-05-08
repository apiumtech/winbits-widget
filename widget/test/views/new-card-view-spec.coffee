'use strict'

NewCardView = require 'views/cards/new-card-view'
$ = Winbits.$

describe 'NewCardViewSpec', ->

  beforeEach ->
    @view = new NewCardView

  afterEach ->
    @view.dispose()

  it 'should render wrapper', ->
    expect(@view.$el).to.has.id('wbi-new-card-view')
    expect(@view.$el).to.has.$class('creditCardNew')

  it 'should be rendered', ->
    expect(@view.$('form#wbi-new-card-form')).to.existExact(1)
    expect(@view.$('#wbi-save-card-btn')).to.existExact(1)
    expect(@view.$('.wbc-cancel-btn')).to.existExact(2)
    expect(@view.$('#wbi-new-card-status-layer')).to.existExact(1)
