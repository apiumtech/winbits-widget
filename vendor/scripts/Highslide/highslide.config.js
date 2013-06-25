/**
*	Site-specific configuration settings for Highslide JS
*/
hs.align = 'center';
hs.allowHeightReduction = false;
hs.blockRightClick = true;
hs.dimmingOpacity = 0.77;
hs.graphicsDir = 'http://widgets.winbits.com/qa/scripts/highslide/graphics/';
// Spanish language strings
hs.lang = {
    cssDirection: 'ltr',
    loadingText: 'Cargando...',
    loadingTitle: 'Click para cancelar',
    focusTitle: 'Click para traer al frente',
    fullExpandTitle: 'Expandir al tamaño actual',
    creditsText: 'Potenciado por <i>Highslide JS</i>',
    creditsTitle: 'Ir al home de Highslide JS',
    previousText: 'Anterior',
    nextText: 'Siguiente',
    moveText: 'Mover',
    closeText: 'Cerrar',
    closeTitle: 'Cerrar (esc)',
    resizeTitle: 'Redimensionar',
    playText: 'Iniciar',
    playTitle: 'Iniciar slideshow (barra espacio)',
    pauseText: 'Pausar',
    pauseTitle: 'Pausar slideshow (barra espacio)',
    previousTitle: 'Anterior (flecha izquierda)',
    nextTitle: 'Siguiente (flecha derecha)',
    moveTitle: 'Mover',
    fullExpandText: 'Tamaño real',
    number: 'Imagen %1 de %2',
    restoreTitle: 'Click para cerrar la imagen, click y arrastrar para mover. Usa las flechas del teclado para avanzar o retroceder.'
};
hs.outlineType = null; // Fondo transparente
hs.onDimmerClick = function() {
  return false;
} // Previene que se cierre el modal en el click en el overlay
hs.preserveContent = false;
hs.registerOverlay({
	html: '<div class="icon closeButton" onclick="return hs.close(this)" title="Cerrar"></div>',
	position: 'top right',
	useOnHtml: true,
	fade: 2 // fading the semi-transparent overlay looks bad in IE
});
hs.showCredits = false;
hs.transitions =["fade"];
hs.wrapperClassName = 'borderless';
