'use strict'

CartPaymentMethodsView = require 'views/cart/cart-payment-methods-view'
Cart = require 'models/cart/cart'
utils = require 'lib/utils'
EventBroker = Chaplin.EventBroker
$ = Winbits.$

describe 'CartPaymentMethodsViewSpec', ->

  beforeEach ->
    @model = new Cart
    @view = new CartPaymentMethodsView model: @model

  afterEach ->
    utils.showLoadingMessage.restore?()
    @view.checkout.restore?()
    @view.dispose()

  it 'should be rendered', ->
    expect(@view.$el).to.has.id('wbi-cart-payment-methods')
    expect(@view.$ '#wbi-cart-checkout-btn').to.exist
    expect(@view.$ '#wbi-continue-shopping-link').to.exist

  it.skip 'should copies be correct', ->
    expect(@view.$ '#wbi-cart-checkout-btn').to.has.$val('Comprar Ahora')
    expect(@view.$ '#wbi-continue-shopping-link').to.has.$text('CONTINUAR COMPRANDO')

  it 'should call checkout when checkout button is clicked', ->
    sinon.stub(@view, 'checkout')

    @view.$('#wbi-cart-checkout-btn').click()

    expect(@view.checkout).to.has.been.calledOnce

  it 'should call checkout when "checkout-requested" event is triggered', ->
    sinon.stub(@view, 'checkout')

    EventBroker.publishEvent('checkout-requested')

    expect(@view.checkout).to.has.been.calledOnce

  it 'checkout should show loading message prior to request checkout', sinon.test ->
    @stub(utils, 'isLoggedIn').returns yes
    @stub(utils, 'showLoaderToCheckout')
    @stub(@model, 'requestCheckout')

    @view.checkout()

    expect(utils.showLoaderToCheckout).to.has.been.calledOnce

  it 'checkout should request checkout service through model', sinon.test ->
    @stub(utils, 'isLoggedIn').returns yes
    @stub(utils, 'showLoadingMessage')
    @stub(@model, 'requestCheckout')

    @view.checkout()

    expect(@model.requestCheckout).to.has.been.calledOnce

  it 'checkout call login', sinon.test ->
    @stub(utils, 'isLoggedIn').returns no
    @stub(utils, 'redirectTo')
    @stub(utils, 'showLoadingMessage')
    @stub(@model, 'requestCheckout')

    @view.checkout()
    expect(@model.requestCheckout).to.not.has.been.called
    expect(utils.redirectTo).to.has.been.calledOnce

