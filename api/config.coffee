exports.config =
# See http://brunch.io/#documentation for docs.
  files:
    javascripts:
      joinTo:
        'js/app.js': /^(bower_components|vendor)/
      order:
      # Files in `vendor` directories are compiled before other files
      # even if they aren't specified in order.before.
        before: [
          'bower_components/modernizr/modernizr.js'
          'bower_components/console-polyfill/index.js'
          'vendor/scripts/init.coffee'
        ]
        after: [
          'vendor/scripts/rpc.coffee'
        ]
