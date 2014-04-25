chai.use (chai, utils) ->

  inspect = (obj) ->
    obj.selector or utils.inspect.apply(@, arguments)

  ###
  Check an object has certain classes.
  Expects @_obj to be a jQuery object.
  ###
  chai.Assertion.addMethod 'classes', (classes)->
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

  # Revisa que un número exacto de elementos existan.
  # Espera que @_obj sea un objeto jQuery.
  chai.Assertion.addMethod 'existExact', (expected) ->
    new chai.Assertion(@_obj).to.exist
    el = inspect(@_obj)
    existent = @_obj.length
    @assert existent is expected
    , "expected exactly #{expected} #{el} to exist but found #{existent}"
    , "expected more or less #{el} to exist than #{expected}"

  # Revisa si el elemento está desplegado conforme al valor de la regla CSS 'display'.
  # Espera que @_obj sea un objeto jQuery.
  chai.Assertion.addProperty 'displayed', () ->
    el = inspect(@_obj)
    regexp = /display:\s*none;/i
    @assert not regexp.test(@_obj.attr('style'))
    , "element #{el} is not displayed"
    , "element #{el} is displayed"

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
