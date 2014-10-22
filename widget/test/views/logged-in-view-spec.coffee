'use strict'

LoggedInView =  require 'views/logged-in/logged-in-view'
LoggedInModel = require 'models/logged-in/logged-in'
utils = require 'lib/utils'
EventBroker = Chaplin.EventBroker
mediator = Winbits.Chaplin.mediator
$ = Winbits.$

describe 'LoggedInViewSpec', ->

  beforeEach ->
    @loginData =
      id: 19
      apiToken: '6ue7zrBfNkxgNTvT4ReGpuh55yjNLRl6qEHiXMFyXFx6M3ymV21EaARwilDZK0zM'
      bitsBalance: 0
    mediator.data.set 'login-data', @loginData
    @model = new LoggedInModel @loginData
    @view = new LoggedInView model: @model

  afterEach ->
    utils.ajaxRequest.restore?()
    @view.dispose()
    mediator.data.clear()

  it 'logged in view renderized', ->
    expect(@view.$el).to.has.class('miCuenta')
    expect(@view.$ '#wbi-my-account-link').to.exist
      .and.to.has.classes(['spanDropMenu', 'link'])
    expect(@view.$ '#wbi-user-cart').to.exist
    expect(@view.$ 'input#wbi-checkout-btn').to.exist

  it 'should trigger "checkout-requested" event when clicked', ->
    stub = sinon.stub()
    EventBroker.subscribeEvent('checkout-requested', stub)

    @view.$('#wbi-checkout-btn').click()
    expect(stub).to.has.been.calledOnce

