'use strict'

CartPaymentMethodsView = require 'views/cart/cart-payment-methods-view'
Cart = require 'models/cart/cart'
utils = require 'lib/utils'
EventBroker = Chaplin.EventBroker
$ = Winbits.$

describe 'CartPaymentMethodsViewSpec', ->

  RESPONSE_CART_ITEMS = {"paymentMethods":[{"id":2,"identifier":"cybersource.cc","maxAmount":100000,"minAmount":0.01,"displayOrder":1,"offline":false,"logo":null},{"id":3,"identifier":"cybersource.token","maxAmount":100000,"minAmount":0.01,"displayOrder":1,"offline":false,"logo":null},{"id":12,"identifier":"amex.cc","maxAmount":100000,"minAmount":200,"displayOrder":1,"offline":false,"logo":null},{"id":17,"identifier":"paypal.latam","maxAmount":40000,"minAmount":15,"displayOrder":3,"offline":false,"logo":null},{"id":18,"identifier":"paypal.msi","maxAmount":40000,"minAmount":15,"displayOrder":3,"offline":false,"logo":null}],"cashback":0}

  beforeEach ->
    @model = new Cart(RESPONSE_CART_ITEMS)
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


  it 'Render payment methods ', ->
    expect(@view.$('.iconFont-paypal')).to.exist
    expect(@view.$('.iconFont-amex')).to.exist
    expect(@view.$('.iconFont-visa')).to.exist
    expect(@view.$('.iconFont-mastercard')).to.exist
    expect(@view.$('.iconFont-billete')).to.not.exist


