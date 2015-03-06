'use strict'
NewsregisterModalView = require 'views/newsregister/newsregister-modal-view'
utils = require 'lib/utils'
mediator = Winbits.Chaplin.mediator

describe 'NewsregisterModalViewSpec', ->

  before ->
    $.validator.setDefaults ignore: []

  after ->
    $.validator.setDefaults ignore: ':hidden'

  beforeEach ->
    @view = new NewsregisterModalView(autoAttach:no)
    sinon.stub(@view, 'showAsModal')
    @view.attach()

  afterEach ->
    @view.showAsModal.restore()
    @view.dispose()

  it 'Newsregister modal will be renderized', ->
    expect(@view.$('#wbi-go-login-button')).to.exist

  #it 'When click on button, call onLoginButtonClick function',->
    #  sendFunction = sinon.stub(@view,'onLoginButtonClick')
    #@view.$('#wbi-go-login-button').click()
    #expect(sendFunction).called