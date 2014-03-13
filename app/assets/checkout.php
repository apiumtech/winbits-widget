<!DOCTYPE html>
<?php
  $token = $_POST['token'];
  $order_id = $_POST['order_id'];
  $bits_balance = $_POST['bits_balance'];
  $verticalId = $_POST['vertical_id'];
  $verticalUrl = $_POST['vertical_url'];
  $timestamp = $_POST['timestamp'];

  if ($_SERVER['REQUEST_METHOD'] == 'POST' && isset($token) && isset($order_id) && isset($verticalId)) {
?>
<html lang="es">
<head>
  <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
  <meta charset="utf-8">
  <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1">
  <meta name="description" content="">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <!-- <noscript>
      <meta http-equiv="Refresh" content="0;URL="include/disabledJavaScript.html">
  </noscript> -->
  <link rel="shortcut icon" href="images/favicon.ico" type="image/vnd.microsoft.icon">
  <link rel="icon" href="images/favicon.ico" type="image/vnd.microsoft.icon">
  <link rel="author" href="humans.txt">
  <title>Winbits</title>
  <link rel="stylesheet" href="http://widgets.winbits.com/qa/stylesheets/checkout.css">
  <script src="//ajax.googleapis.com/ajax/libs/jquery/1.10.2/jquery.min.js"></script>
  <script type="text/javascript">
    Winbits = { checkoutConfig: {} };
    Winbits.$ = $.noConflict(true);
    window.w$ = Winbits.$;
  </script>
  <script src="http://widgets.winbits.com/qa/javascripts/vendor.js"></script>
  <script type="text/javascript">
    Backbone.$ = Winbits.$;
    Winbits.checkoutConfig.orderId='<?echo $order_id?>';
    Winbits.checkoutConfig.providerUrl = 'https://apici.winbits.com/provider/';
    Winbits.token= '<?echo $token?>';
    Winbits.checkoutConfig.bitsBalance = '<?echo $bits_balance?>';
    Winbits.checkoutConfig.verticalId = '<?echo $verticalId?>';
    Winbits.checkoutConfig.verticalUrl = '<?echo $verticalUrl?>';
    Winbits.checkoutConfig.timestamp = '<?echo $timestamp?>';
  </script>
  <script src="http://widgets.winbits.com/qa/javascripts/app.js"></script>
  <script>
    window.Winbits.$(document).ready(function($) {
      var Application = require('application');
      (new Application).initialize(true);
    });
  </script>
</head>
<body>
  <div id="main"></div>
</body>
</html>
<? } else { ?>
<html lang="es">
  <head>
    <meta http-equiv="refresh" content="0;URL='http://www.winbits.com/'" />
  </head>
  <body>Redireccionando a Winbits...</body>
</html>
<? } ?>
