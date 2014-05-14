'use strict'
AccountHistoryView = require 'views/account-history/account-history-view'
AccountHistory = require 'models/account-history/account-history'
utils = 'lib/utils'
mediator = Winbits.Chaplin.mediator
$ = Winbits.$

describe 'AccountHistoryViewSpec', ->

  beforeEach ->
    @loginData =
      id: 19
      apiToken: '6ue7zrBfNkxgNTvT4ReGpuh55yjNLRl6qEHiXMFyXFx6M3ymV21EaARwilDZK0zM'
      bitsBalance: 0
      profile:
        pendingOrdersCount: 2
    mediator.data.set 'login-data', @loginData
    @model = new AccountHistory @loginData
    @view = new AccountHistoryView model:@model

  afterEach ->
    @view.dispose()
    @model.dispose()
    mediator.data.clear()

  it 'account history render', ->
    expect(@view.el).exist
    expect(@view.el).is.render
    expect(@view.$('#wbi-account-order-count')).exist
    expect(@view.$('#wbi-account-bits-total')).exist

  it 'account values bits and order rendered', ->
    expect(@view.$('#wbi-account-order-count').text()).is.equal '2'
    expect(@view.$('#wbi-account-bits-total').text()).is.equal '0'
