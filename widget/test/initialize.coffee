
tests = [
  './views/header-view-test',
  './views/login-view-test'
]

for test in tests
    console.log ['Executing tests -> ', test]
    require test
