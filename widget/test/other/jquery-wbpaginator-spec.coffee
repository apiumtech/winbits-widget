testUtils = require 'test/lib/test-utils'
$ = Winbits.$

describe 'jQueryWbPaginatorSpec', ->

  beforeEach ->
    @$el = $('<div></div>')

  afterEach ->

  it 'should be a jQuery plugin', ->
    expect($().wbpaginator).to.be.a('function')
    expect(@$el.wbpaginator()).to.be.equal(@$el)

  it 'should have default options', ->
    @$el.wbpaginator()

    expect(@$el.wbpaginator('option', 'max')).to.be.equal(10)
    expect(@$el.wbpaginator('option', 'page')).to.be.equal(1)

  it 'should set all options', ->
    @$el.wbpaginator(total: 50, max: 5, page: 3)

    expect(@$el.wbpaginator('option', 'total')).to.be.equal(50)
    expect(@$el.wbpaginator('option', 'max')).to.be.equal(5)
    expect(@$el.wbpaginator('option', 'page')).to.be.equal(3)

  it 'should set default max if max lower than 1', ->
    @$el.wbpaginator(total: 100, max: 0)

    expect(@$el.wbpaginator('option', 'max')).to.be.equal(10)

  it 'should set default max if max greater than total', ->
    @$el.wbpaginator(total: 100, max: 200)

    expect(@$el.wbpaginator('option', 'max')).to.be.equal(10)

  it 'should set default page if page lower than 1', ->
    @$el.wbpaginator(total: 95, page: 0)

    expect(@$el.wbpaginator('option', 'page')).to.be.equal(1)

  it 'should set default page if page greater than the number of total pages', ->
    @$el.wbpaginator(total: 100, page: 11)

    expect(@$el.wbpaginator('option', 'page')).to.be.equal(1)
