/**
 * Coverdienst-Einbindung ohne weitere JavaScript-Abhängigkeiten.
 * Benoetigt mindestens IE 9.0 oder anderen Browser.
 */
function escapeHTML(s) {
    return s.replace(/&/g,"&amp;").replace(/"/g,"&quot;")
            .replace(/</g,"&lt;").replace(/>/g,"&gt;");
}

function displayCover(element, size, url) {
    var wantWidth = 1 * element.getAttribute("width");
    var wantHeight = 1 * element.getAttribute("height");
    var attr = "";
    var dim = size.match(/^(\d+)x(\d+)$/);
    if (dim) {
        var w = dim[1], h = dim[2];
        if (w && h) {
            var width = w, height = h;
            if (wantWidth && !wantHeight) {
                width = wantWidth;
                height = h * (wantWidth / w);
            } else if (wantHeight) {
                height = wantHeight;
                width = w * (wantHeight / h);
            }
            attr = 'width="' + width + '" height="' + height + '"';
        }
    }
    element.innerHTML = '<img src="' + escapeHTML(url) + '" ' + attr + '></img>';
}

function getCover(id, callback) {
    var jsonp = "jsonp" + Math.random().toString().substring(2);
    var head = document.getElementsByTagName("head")[0];
    var script = document.createElement("script");
    script.src = "//ws.gbv.de/covers/?format=seealso&callback="+jsonp+"&id="+id;
    script.type = "text/javascript";
    script.charset = "UTF-8";
    window[jsonp] = function(data) {
        if (data[3] && data[3].length) {
            callback(data[2][0], data[3][0]);
        }
        window[jsonp] = undefined; // GC
        try{ delete window[jsonp]; } catch(e){}
        if (head) script.parentNode.removeChild(script);
    };
    head.appendChild(script);
}

// Ersetze alle Elemente mit class=coverdienst
var elements = document.getElementsByClassName('coverdienst');
for (i=0; i<elements.length; i++) {
  var e = elements[i];
  var id = e.getAttribute("title") || "";
  id = id.replace(/^\s+|\s+$/g,"");
  getCover( id, function(label, size, url) {
    displayCover(e, label, size, url);
  });
}
