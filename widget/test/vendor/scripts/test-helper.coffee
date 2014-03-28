###
Check an object has certain classes.
Expects @_obj to be a jQuery object.
###
chai.Assertion.addChainableMethod 'classes', (classes)->
  @assert (x for x in classes when  @_obj.hasClass x).length is classes.length
  , "the element has not classes #{classes}"
  , "the element has classes #{classes}"

# Create `window.describe` etc. for our BDD-like tests.
mocha.setup ui: 'bdd'

# Create another global variable for simpler syntax.
window.expect = chai.expect
