testUtils = require 'test/lib/test-utils'
$ = Winbits.$
_ = Winbits._

describe 'jQueryWbPaginatorSpec', ->

  beforeEach ->
    @$el = $('<div></div>')

  afterEach ->

  it 'should be a jQuery plugin', ->
    expect($().wbpaginator).to.be.a('function')
    expect(@$el.wbpaginator()).to.be.equal(@$el)

  it 'should have default options', ->
    @$el.wbpaginator(total: 100)

    expect(@$el.wbpaginator('option', 'total')).to.be.equal(100)
    expect(@$el.wbpaginator('option', 'max')).to.be.equal(10)
    expect(@$el.wbpaginator('option', 'page')).to.be.equal(1)

  it 'should set all options', ->
    @$el.wbpaginator(total: 50, max: 5, page: 3)

    expect(@$el.wbpaginator('option', 'total')).to.be.equal(50)
    expect(@$el.wbpaginator('option', 'max')).to.be.equal(5)
    expect(@$el.wbpaginator('option', 'page')).to.be.equal(3)

  _.each [0, 'x'], (total) ->
    it "should not set invalid total value: #{total}", ->
      @$el.wbpaginator(total: total)

      expect(@$el.wbpaginator('option', 'total')).to.not.be.ok

  _.each [99.1, 99.5, 99.9], (total) ->
    it "should round total to next integer value: #{total}", ->
      @$el.wbpaginator(total: total)

      expect(@$el.wbpaginator('option', 'total')).to.be.equal(100)

  it 'should set default max if max greater than total', ->
    @$el.wbpaginator(total: 100, max: 200)

    expect(@$el.wbpaginator('option', 'max')).to.be.equal(10)

  _.each [0, 'x', 100.1], (max) ->
    it "should set default max if value invalid: #{max}", ->
      @$el.wbpaginator(total: 100, max: max)

      expect(@$el.wbpaginator('option', 'max')).to.be.equal(10)
  , @

  _.each [49.1, 49.5, 49.9], (max) ->
    it "should round max to next integer value: #{max}", ->
      @$el.wbpaginator(total: 100, max: max)

      expect(@$el.wbpaginator('option', 'max')).to.be.equal(50)
  , @

  _.each [0, 11, 'x', 10.1], (page) ->
    it "should set default page if value invalid: #{page}", ->
      @$el.wbpaginator(total: 100, page: page)

      expect(@$el.wbpaginator('option', 'page')).to.be.equal(1)
  , @

  _.each [9.1, 9.5, 9.9], (page) ->
    it "should round page to next integer value: #{page}", ->
      @$el.wbpaginator(total: 100, page: page)

      expect(@$el.wbpaginator('option', 'page')).to.be.equal(10)
  , @

  it 'should set default max if max greater than total', ->
    @$el.wbpaginator(total: 100, max: 200)

    expect(@$el.wbpaginator('option', 'max')).to.be.equal(10)

  it 'should generate pager', ->
    @$el.wbpaginator(total: 100)

    $pager = @$el.find('p.wbc-pager')
    expect($pager).to.existExact(1)
    expect($pager).to.has.$text('Página 1 de 10')

  it 'should generate pages list', ->
    @$el.wbpaginator(total: 100)

    expect(@$el.find('ul.wbc-pages')).to.existExact(1)

  it 'should generate previous pager', ->
    @$el.wbpaginator(total: 100)

    $previousPager = @$el.find('li.wbc-previous-pager')
    expect($previousPager).to.existExact(1)
    expect($previousPager).to.has.$class('pager-prev')

  it 'should generate previous pager as the first pager', ->
    @$el.wbpaginator(total: 100)

    $firstPager = @$el.find('ul.wbc-pages').children().first()
    expect($firstPager).to.has.$class('wbc-previous-pager')

  it 'should generate previous pager link', ->
    @$el.wbpaginator(total: 100)

    $previousPagerLink = @$el.find('a.wbc-previous-pager-link')
    expect($previousPagerLink).to.existExact(1)
    expect($previousPagerLink.parent()).to.has.$class('wbc-previous-pager')
    expect($previousPagerLink).to.has.$text(' Ant')

  it 'should generate previous pager arrow', ->
    @$el.wbpaginator(total: 100)
    $arrowSpan = @$el.find('.wbc-previous-pager-link').children()
    expect($arrowSpan).to.has.$class('iconFont-arrowLeft')

  it 'should generate next pager', ->
    @$el.wbpaginator(total: 100)

    $nextPager = @$el.find('li.wbc-next-pager')
    expect($nextPager).to.existExact(1)
    expect($nextPager).to.has.$class('pager-next')

  it 'should generate next pager as the last pager', ->
    @$el.wbpaginator(total: 100)

    $firstPager = @$el.find('ul.wbc-pages').children().last()
    expect($firstPager).to.has.$class('wbc-next-pager')

  it 'should generate next pager link', ->
    @$el.wbpaginator(total: 100)

    $nextPagerLink = @$el.find('a.wbc-next-pager-link')
    expect($nextPagerLink).to.existExact(1)
    expect($nextPagerLink.parent()).to.has.$class('wbc-next-pager')
    expect($nextPagerLink).to.has.$text('Sig ')

  it 'should generate next pager arrow', ->
    @$el.wbpaginator(total: 100)
    $arrowSpan = @$el.find('.wbc-next-pager-link').children()
    expect($arrowSpan).to.has.$class('iconFont-arrowRight')

  it 'should generate correct number of pages', ->
    @$el.wbpaginator(total: 100)

    expect(@$el.find('li.wbc-page').length).to.be.equal(10)
    expect(@$el.find('a.wbc-page-link').length).to.be.equal(10)

  it 'should generate pages', ->
    @$el.wbpaginator(total: 100)

    $pages = @$el.find('li.wbc-page')
    for page in [1, 10]
      $page = $pages.eq(page - 1)
      expect($page).to.has.$text(page.toString())

  it 'should render correct page option', ->
    @$el.wbpaginator(total: 100, page: 5)

    expect(@$el.find('.wbc-pager')).to.has.$text('Página 5 de 10')
