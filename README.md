# GBV Coverdienst

Dieses Repository enthält einen Dummy für Clients, die noch immer auf einen alten Coverdienst unter <http://ws.gbv.de/covers/> zugreifen. Der alte Code ist im `legacy` branch.

Der Webservice besteht aus eienr nginx-Konfiguration, die basierend auf dem Query-Parameter `format` eine JSON-Datei oder eine GIF-Datei (1x1 transparenter Pixel) zurückliefert.
