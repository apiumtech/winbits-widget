// ++++++++++++++++++++++++++++++++++++++++++++++++
//      OLDNAV: Navegadores viejos
// ++++++++++++++++++++++++++++++++++++++++++++++++

function oldnav(obj){
	if($('.msie6, .msie7, .msie8').length){
		if(!($('.modalWindow').length)){
			if(!($('.'+obj).length)){
				var actText = '<nav>\r\n';
				actText += '		<a href="#" class="vermas">Ver más</a>\r\n';
				actText += '		<a href="#" class="vermenos">Ver menos</a>\r\n';
				actText += '		<a href="#" class="nomore">No mostrar más</a>\r\n';
				actText += '		<a href="#" class="close">X</a>\r\n';
				actText += '</nav>\r\n';
				actText += '	<p>Este sitio funciona con un amplio rango de navegadores. ';
				actText += 'Sin embargo, si quieres usar nuestras últimas y grandiosas características, ';
				actText += 'por favor actualiza a la más reciente versión de un moderno y totalmente compatible navegador.</p>\r\n';
				actText += '<p>Encuentra la última versión de lo navegadores soportados:</p>\r\n';
				actText += '<ul>\r\n';
				actText += '	<li><a href="http://www.google.com/chrome/" target="_blank">Chrome</a></li>\r\n';
				actText += '	<li><a href="http://www.mozilla.com/" target="_blank">Firefox</a></li>\r\n';
				actText += '	<li><a href="http://www.apple.com/safari/download/" target="_blank">Safari</a></li>\r\n';
				actText += '	<li><a href="http://windows.microsoft.com/es-ES/internet-explorer/products/ie/home" target="_blank">Internet Explorer</a></li>\r\n';
				actText += '</ul>\r\n';
				actText += '<p>Tengo Windows XP y no puedo actualizar a IE9, ¿qué hago?</p>\r\n';
				actText += '<ol>\r\n';
				actText += '	<li>Descarga <a href="http://www.google.com/chromeframe/" target="_blank">Chrome Frame</a> ';
				actText += 'para hacer tu experiencia desde IE6, 7 u 8 mucho más rápida.</li>\r\n';
				actText += '<li>Descarga otros navegadores que si pueden ser instalado en XP ';
				actText += '(<a href="http://www.google.com/chrome/" target="_blank">Chrome</a>';
				actText += ' o <a href="http://www.mozilla.com/" target="_blank">Firefox</a> por ejemplo).</li>\r\n';
				actText += '</ol>\r\n';
				//Tools.eraseCookie('actualiza');
				var showActualiza = Tools.readCookie('actualiza');
				if(!(showActualiza)){
					$('body').prepend('<div class="'+obj+'"/>');
					$('body').find('.'+obj).html(actText);
					$('body').find('.'+obj).find('.close').click(function(){
						$('body').find('.'+obj).slideToggle();
					});
					$('body').find('.'+obj).find('.vermas').click(function(){
						$(this).hide();
						$('body').find('.'+obj).find('.vermenos').css('display','inline-block');
						$('body').find('.'+obj).animate({
							height: '300px'
						});
					});
					$('body').find('.'+obj).find('.vermenos').click(function(){
						$(this).hide();
						$('body').find('.'+obj).find('.vermas').css('display','inline-block');
						$('body').find('.'+obj).animate({
							height: '50px'
						});
					});
					$('body').find('.'+obj).find('.nomore').click(function(){
						Tools.createCookie('actualiza', true, 7);
						$('body').find('.'+obj).slideToggle();
					});
				}
			}
		}
	}
}

var Tools = {
	createCookie: function(name, value,days) {
		if (days) {
			var date = new Date();
			date.setTime(date.getTime()+(days*24*60*60*1000));
			var expires = "; expires="+date.toGMTString();
		} else var expires = "";
			document.cookie = name+"="+value+expires+"; path=/";
		},
	readCookie: function(name) {
		var nameEQ = name + "=";
		var ca = document.cookie.split(';');
		for(var i=0;i < ca.length;i++) {
			var c = ca[i];
			while (c.charAt(0)==' ') c = c.substring(1,c.length);
			if (c.indexOf(nameEQ) == 0) return c.substring(nameEQ.length,c.length);
		}
		return null;
	},
	eraseCookie: function(name) {
		Tools.createCookie(name,"",-1);
	}
};

oldnav('actualiza');