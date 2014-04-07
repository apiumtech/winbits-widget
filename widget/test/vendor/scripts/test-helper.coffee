###
Check an object has certain classes.
Expects @_obj to be a jQuery object.
###
chai.Assertion.addChainableMethod 'classes', (classes)->
  @assert (x for x in classes when  @_obj.hasClass x).length is classes.length
  , "the element has not classes #{classes}"
  , "the element has classes #{classes}"

chai.Assertion.addProperty 'wbRadioChecked', ()->
  $radio = @_obj
  $radioLabel = $radio.prev()
  @assert $radio.is(':checked')
  , "the radio #{$radio.selector} is not checked"
  , "the radio #{$radio.selector} is checked"

  @assert $radioLabel.is('.radio-selected')
  , "the radio label has not selected class"
  , "the radio label has selected class"

window.TestUtils = {
  promises: {
    resolved: new $.Deferred().resolve().promise()
    rejected: new $.Deferred().reject().promise()
  }
}

# Create `window.describe` etc. for our BDD-like tests.
mocha.setup ui: 'bdd'

# Create another global variable for simpler syntax.
window.expect = chai.expect
