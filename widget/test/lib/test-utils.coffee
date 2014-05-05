# Application-specific utilities
# ------------------------------

# Delegate to Chaplin’s utils module.
testUtils = {}

# _(utils).extend
#  someMethod: ->
_(testUtils).extend
  promiseResolvedWithData: (extraZipCodeInfo) ->
    zipCodeData = response: [@generateZipCodeInfo(), @generateZipCodeInfo(id: 2, locationName: 'Lomas Virreyes')]
    zipCodeData.response.push(extraZipCodeInfo) if extraZipCodeInfo
    new $.Deferred().resolve(zipCodeData).promise()

  generateZipCodeInfo: (data) ->
    $.extend(
      id: 1,
      locationName: 'Lomas Chapultepec',
      locationCode: '00',
      locationType: 'Colonia',
      county: 'Miguel Hidalgo',
      city: 'Miguel Hidalgo',
      state: 'DF',
      zipCode: '11000'
    , data)

 # Prevent creating new properties and stuff.
Object.seal? testUtils
module.exports = testUtils
