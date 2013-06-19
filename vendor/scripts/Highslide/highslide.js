loadFiles("include/js/libs/Highslide/");


function loadFiles(path) {
	var escribe = '<link rel="stylesheet" href="' + path + 'highslide.css">\n';
	escribe += '<!--[if lt IE 7]>\n';
	escribe += '<link rel="stylesheet" type="text/css" href="' + path + 'highslide-ie6.css" />\n';
	escribe += '<![endif]-->\n';
	escribe += '<script src="' + path + 'highslide-full.packed.js"><\/script>\n';
	escribe += '<script src="' + path + 'highslide.config.js"><\/script>\n';
	document.write(escribe);
}