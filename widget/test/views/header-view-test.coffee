HeaderView = require "views/header/header-page-view"
LoginView = require "views/login/login-view"
FooterView = require "views/footer/footer-page-view"
class HeaderViewTest

describe 'HeaderView', ->
  beforeEach ->
    @view = new HeaderView
    @loginView = new LoginView
    @footerView = new FooterView

  afterEach ->
    @view.dispose()

  it 'check renderized', ->
    expect(@view.$el.find 'widgetWinbitsHeader').to.exist
  
  it 'find login container', ->
    expect(@loginView.$el.find '.mainHeader .wrapper .login').to.exist

  it 'find footer container', ->
    expect(@footerView.$el.find 'footer').to.exist
