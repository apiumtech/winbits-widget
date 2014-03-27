
tests = [
  './views/header-view-test'
]

for test in tests
    console.log ['Executing tests -> ', test]
    require test
