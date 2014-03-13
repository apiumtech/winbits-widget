<?php
$verticalUrl = $_GET['verticalUrl'];
$orderId = $_GET['orderId'];

$ch = curl_init();
// set URL and other appropriate options
curl_setopt($ch, CURLOPT_URL, "https://apici.winbits.com/v1/orders/orders/".$orderId.".json");
curl_setopt($ch, CURLOPT_HEADER, false);
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
// grab URL and pass it to the browser
$json = curl_exec($ch);
// close cURL resource, and free up system resources
curl_close($ch);
//$json = '{"meta":{"status":200},"response":{"email":"manuel.android.dev+1@gmail.com","id":415,"orderNumber":"1310111808--415","itemsTotal":10,"shippingTotal":250,"bitsTotal":50,"total":260,"cashTotal":260,"status":"PENDING","orderDetails":[{"id":415,"shippingAmount":0,"amount":10,"quantity":1,"sku":{"id":3,"name":"name0","fullPrice":20,"price":10,"stock":90,"mainAttribute":{"name":"atributoName","label":"atributoLabel","type":"TEXT","value":"AtributoLAbel"},"attributes":[{"name":"attribute0","label":"label0","value":"value0","type":"TEXT"},{"name":"attribute1","label":"label1","value":"value1","type":"TEXT"},{"name":"attribute2","label":"label2","value":"value2","type":"TEXT"}],"thumbnail":"http://urltoimage","vertical":{"id":1,"baseUrl":"http://www.clickonero.com","logo":null,"maxPerVertical":1000,"name":"clickOnero"},"brand":{"id":1,"dateCreated":"2013-09-17T12:18:23-05:00","deleted":false,"description":"marca patito","lastUpdated":"2013-09-17T12:18:23-05:00","logo":null,"name":"PATITO BRAND","vertical":{"class":"Vertical","id":1}}},"requiresShipping":true}],"paymentMethods":[],"vertical":{"id":2},"shippingOrder":{"contactName":"manuel gomez","contactPhone":"1234567890","street":"fco","location":null,"indications":"cdcdcdc","betweenStreets":"aqaqa","internalNumber":"1","externalNumber":"71","locationName":"","locationCode":"013","locationType":"Barrio","county":"","city":"Ciudad de México","state":"Distrito Federal","zipCode":"16050"}}}';

$orderData = json_decode($json, true);

$order = $orderData['response'];
$shipping = $order['shippingOrder'];
$orderDetails = $order['orderDetails'];
$orderPayments = $order['paymentMethods'];
$totalFullPrice = 0;
foreach ($orderDetails as $detail ) {
	$totalFullPrice+= $detail['quantity'] * $detail['sku']['fullPrice'];
}
$totalDiscount = $totalFullPrice - $order['itemsTotal'] - $order['bitsTotal'];
$shippingNotEmpty = 0;
if (!empty($shipping)) {
    $shippingNotEmpty = 1;
}
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
            <? if (!empty($shipping)) { ?>
            <div class="checkoutShipping" >
                <h2>DIRECCIÓN DE ENVIO<span class="circuledNumber">1</span></h2>
                <address>
                    <span><? echo $shipping['contactName']; ?></span>
                    <span><? echo $shipping['street'].' '.$shipping['externalNumber'] ?><? echo (empty($shipping['internalNumber'])) ? ', ' : ' int '.$shipping['internalNumber'].','?></span>
                    <span><? echo $shipping['locationName'].", ".$shipping['county']?></span>
                    <span><? echo $shipping['city'].', '.$shipping['zipCode']?></span>
                </address>
            </div>
            <? } ?>
            <div class="checkoutPayment">
                <h2>INFORMACIÓN DE PAGO <span class="circuledNumber"><? echo $shippingNotEmpty+1 ?></span></h2>
                <address>
                    <span>Cobro exitoso vía Pay Pal de: <? echo (empty($order['cashTotal'])) ? '' : ' $'.$order['cashTotal'] ?></span>

                </address>
            </div>
            <div class="checkoutSummary">
                <h2>RESUMEN <span class="circuledNumber"><? echo $shippingNotEmpty+2 ?></span></h2>
                <? if (!empty($order['estimatedDeliveryDate'])) { ?>
                <div class="checkoutResumen" >
                    <h3>ENTREGA</h3>

                    <p>Fecha estimada de entrega:<span><? echo $order['estimatedDeliveryDate'] ?></span></p>
                </div>
                <? } ?>
                <div class="checkoutResumen">
                    <h3>ORDEN DE COMPRA</h3>
                    <p><b><? echo $order['orderNumber']?></b></p>
                    <p>Tu orden de compra se enviará a la siguiente dirección:<span><? echo $order['email']; ?></span></p>
                </div>
                <div class="checkoutButton">
                    <a href="<? echo $verticalUrl?>" class="btn btnCheckout">Volver a la tienda</a>
                </div>
            </div>
        </div>
        <aside>
            <h2>TU ORDEN</h2>
            <ul>
                <? foreach ($orderDetails as $detail) { ?>
                <li>

                    <a href="#"><img src="<? echo $detail['sku']['thumbnail'] ?>" width="28" height="36"
                                     alt="<?echo $detail['sku']['name'] ?>"></a>
                    <p><?echo $detail['sku']['name'] ?>
                        <?
                	$attrList = $detail['sku']['mainAttribute']['label'];
                	foreach ($detail['sku']['attributes'] as $attribute) {
                		$attrList = $attrList.', '.$attribute['label'];
                	}                                  	
                	?>

                        <span><?echo '('.$detail['quantity'].')' ?> <? echo $attrList;?></span>
                        <span><b><?echo '$'.$detail['quantity']*$detail['sku']['price'] ?></b></span>
                    </p>
                </li>
                <?}?>
            </ul>
            <div class="checkoutSubtotal">
                <span>PRECIO ORIGINAL</span>
                <span><? echo "$".$totalFullPrice?></span>
                <span>SUBTOTAL</span>
                <span><? echo "$".$order['itemsTotal']?></span>
                <span>ENVIO</span>
                <span><? echo $order['shippingTotal']=='0' ? "GRATIS" : "$".$order['shippingTotal']; ?></span>
                <span>GANAS</span>
                <span><span class="icon winbits10px"></span><? echo $order['cashback'] ?></span>
                <? if (!empty($order['bitsTotal'])) { ?>
                <span>PAGO EN BITS</span>
                <span><span class="icon winbits10px"></span><? echo "-".$order['bitsTotal'] ?></span>
                <? } ?>
            </div>
            <div class="checkoutTotal">
                <span class="checkoutTitle">TOTAL</span>
                        <span class="checkoutDetail"><? echo $order['total']?>
                            <span class="note"><? echo "Ahorro de $".$totalDiscount ?></span></span>
            </div>
        </aside>
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