# Chai assert extensions

###
Check an object is rendered.
Expects @_obj to be a jQuery object.
###
chai.Assertion.addProperty 'rendered', ->
  selector = @_obj.selector
  @assert @_obj.length > 0
    , "expected #{selector} is not rendered"
    , "expected #{selector} is rendered"

###
Check an object has a certain id.
Expects @_obj to be a jQuery object.
###
chai.Assertion.addChainableMethod 'id', (id)->
  @assert @_obj.attr('id') is id
    , "element has not id #{id}"
    , "element has id #{id}"

###
Check an object has a certain class.
Expects @_obj to be a jQuery object.
###
chai.Assertion.addChainableMethod 'class', (clazz)->
  @assert @_obj.hasClass(clazz)
    , "the element has not class #{clazz}"
    , "the element has class #{clazz}"

###
Check an object has certain text.
Expects @_obj to be a jQuery object.
###
chai.Assertion.addChainableMethod 'text', (text)->
  @assert @_obj.text() is text
    , "the element has not text #{text}"
    , "the element has text #{text}"

# Create `window.describe` etc. for our BDD-like tests.
mocha.setup ui: 'bdd'

# Create another global variable for simpler syntax.
window.expect = chai.expect
