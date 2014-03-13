<?php
$verticalUrl = $_GET['verticalUrl'];
?>
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="utf-8">
  <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1">
  <meta name="description" content="">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <!-- <noscript>
      <meta http-equiv="Refresh" content="0;URL="include/disabledJavaScript.html">
  </noscript> -->
  <title>Winbits</title>
  <link rel="shortcut icon" href="../images/favicon.ico" type="image/vnd.microsoft.icon">
  <link rel="icon" href="../images/favicon.ico" type="image/vnd.microsoft.icon">
  <link rel="author" href="../humans.txt">
  <link rel="stylesheet" href="http://widgets.winbits.com/qa/stylesheets/checkout.css">
</head>
<body>
<header>
  <div class="widgetWinbitsHeader">
    <div class="knowmoreFolder">
      <div class="wrapper">
        <div class="knowMoreMax">
          <a href="#" class="icon winbits22px">Logo Winbits</a>

          <p>UNA SOLA CUENTA, UN SOLO CHECK OUT, <br>Y EN TODOS GANAS WINBITS.</p>
          <ul>
            <li>
              <span class="icon shopCar">Shop Car</span>

              <p>COMPRA<br>Y GANA WINBITS</p>
            </li>
            <li>
              <a href="#" target="_blank" class="icon twitter">Twitter</a>
              <a href="#" target="_blank" class="icon facebook">Facebook</a>

              <p>COMPARTE<br>Y GANA WINBITS</p>
            </li>
            <li>
              <span class="icon winbitsEqualToMoney">Winbits = Money</span>

              <p>USA TUS WINBITS COMO<br>DINERO ELECTRÓNICO</p>
            </li>
          </ul>
          <fieldset>
            <label>INSCRIBETE AHORA</label>
            <input type="text" placeholder="Email" class="emailJoinNow" name="winbitsEmailJoinNow"
                   id="winbitsEmailJoinNow">
            <span class="btn btnSmall">Join Now</span>
          </fieldset>
          <span class="icon closeFolder openClose"></span>
        </div>
        <div class="knowMoreMin">
          <p>Compra en nuestro sitio y gana! <a href="#">Conoce mas.</a>
            <span class="icon openFolder openClose"></span>
            <div class="language">
              <span><a href="#" class="icon winbits19px">Logo Winbits</a></span>
            </div>
        </div>
      </div>
    </div>
    <div class="mainHeader">
      <div class="wrapper">
        <div class="winbitsLogoDiv">
          <span class="icon winbitsLogo"></span>
        </div>
      </div>
    </div>
  </div>
</header>
<main class="widgetWinbitsMain">
  <div class="wrapper checkoutWinbits">
    <div class="checkoutMain">
      <!-- PAY PAL RECHAZADA -->
      <div class="checkoutPayPal">
        <div class="checkoutPayPal-logo">
          <span class="icon paypalLogo">Pay Pal</span>
          <span class="icon rechazada">Rechazada</span>
        </div>
        <div class="checkoutPayPal-container">
          <h4>Tu compra fué rechazada.</h4>

          <p>Puedes revisar el estado de tu validación en el <a href="<?echo $verticalUrl?>">historial de tu cuenta</a></p>
        </div>
        <div class="checkoutPayPal-submit">
          <a href="<?echo $verticalUrl?>" class="btn">Volver a la tienda</a>
        </div>
      </div>
    </div>
  </div>
</main>
<footer>
  <div class="widgetWinbitsFooter">
    <div class="wrapper">
      <div class="logo">
        <a href="#" class="icon winbits19px">Logo Winbits</a>
      </div>
      <nav>
        <ul>
          <li><a href="#">Welcome</a></li>
          <li><a href="#">My account</a></li>
          <li><a href="#">Need Help?</a></li>
          <li><a href="#">Contact Us</a></li>
          <li><a href="#">International</a></li>
        </ul>
        <ul>
          <li><a href="#">Welcome</a></li>
          <li><a href="#">My account</a></li>
          <li><a href="#">Need Help?</a></li>
          <li><a href="#">Contact Us</a></li>
          <li><a href="#">International</a></li>
        </ul>
        <ul>
          <li><a href="#">Welcome</a></li>
          <li><a href="#">My account</a></li>
          <li><a href="#">Need Help?</a></li>
          <li><a href="#">Contact Us</a></li>
          <li><a href="#">International</a></li>
        </ul>
        <ul>
          <li><a href="#">Welcome</a></li>
          <li><a href="#">My account</a></li>
          <li><a href="#">Need Help?</a></li>
          <li><a href="#">Contact Us</a></li>
          <li><a href="#">International</a></li>
        </ul>
      </nav>
    </div>
  </div>
</footer>
</body>
</html>