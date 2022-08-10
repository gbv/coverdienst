# GBV Coverdienst

Dieser Webservice liefert bei Übergabe einer ISBN ein dazugehöriges Cover aus dem K10plus-Katalog.

## Funktionsweise

Die Abfrage besteht (aus Gründen der Rückwärtskompatibilität gegenüber dem eingestellten SeeAlso-Coverdienst) aus zwei Query-Parametern:

- `format=img`

- `id` die gesuchte ISBN (mit oder ohne Bindestriche, ISBN-13 oder ISBN-10)

Bei Übergabe einer korrekten ISBN wird diese per SRU im K10plus gesucht. Die gefundenen Titel werden ausgewertet und das erste Cover aus Feld [017G=4960](https://format.k10plus.de/k10plushelp.pl?cmd=kat&val=4960&katalog=Standard#$q) zurückgeliefert. Dabei gilt entsprechend der Katalogisierungsrichtline:

- Unterfeld `3` muss den Wert `Cover` haben

- Unterfeld `S` darf nicht `0` sein (Weitergabe nicht gestattet)

- Unterfeld `q` muss den Wert `image/jpeg` haben oder die URL muss auf `.jpg` oder `.jpeg` enden

*Das heisst Cover ohne Formatangabe und Cover die in anderen Formaten als JPEG vorliegen werden ignoriert bis die Katalogisierung angepasst ist!*

Die gefundenen Cover werden nach ihrer ISBN im lokalen Cache-Verzeichnis `data/` abgelegt.

Wenn kein Cover gefunden wurde, wird eine 1x1 Pixel große transparentes GIF-Datei zurückgeliefert.

Query-Parameter `format=seealso` liefert Informationen über das Bild (u.A. die Größe), so dass überprüft werden kann, ob ein Bild vorhanden ist.

## Installation und Konfiguration

Es empfiehlt sich, Perl-Module vorab als Debian-Paket zu installieren (als root). Zumindest `starman` sollte als Systempaket installiert sein:

    sudo apt-get install libcatmandu-sru-perl libplack-perl libbusiness-isbn-perl libimage-size-perl starman

Der Dienst kann grundsätzlich als beliebiger Nutzer laufen, es empfiehlt sich aber ein spezieller Account:

    sudo adduser --home /srv/coverdienst coverdienst --disabled-password
    sudo -iu coverdienst
    git clone --bare https://github.com/gbv/coverdienst.git .git
    git config --unset core.bare
    git checkout

Die noch fehlenden Perl-Module werden in `./local` installiert:

    make deps

Der Dienst kann nun testweise auf Port :5000 gestartet werden:

    make run

Das Cache-Verzeichnis `./data` kann auch per Symlink an anderer Stelle abgelegt werden oder per Umgebungsvariable `COVERDIENST_DATA` festgelegt werden. Es muss aber vom Service schreibbar sein. Die Entfernung oder Aktualisierung von Dateien aus dem Cache wird nicht unterstützt, kann aber per Hand erfolgen. Die Unterverzeichnis des Cache ergeben sich aus der vierten bis sechsten Ziffer der ISBN (ohne Bindestriche), z.B. Cover für ISBN 9782330004576 in `./data/233/9782330004576.jpg`.

Für die Installation als Service sollte der Perl-Webserver Starman verwendet werden, z.B.

    starman --workers 5 --port 6027

Zur dauerhaften Installation als Service gibt es verschiedene Möglichkeiten, diesen Aufruf dauerhaft, d.h. beim Booten und nach Absturz des Dienst, einzurichten. Die Datei `coverdienst.service` enthält ein Beispiel für Systemd. Die Datei setzt vorraus, dass der Coverdienst in `/srv/coverdienst` als Benutzer `coverdienst` installiert ist (muss je nach Installation angepasst werden):

    sudo cp coverdienst.service /etc/systemd/system
    sudo systemctl enable coverdienst
    sudo systemctl start coverdienst

### Logging

Fehlermeldungen und Mitteilungen welche Coverdateien heruntergeladen wurden stehen im systemlog:

    sudo journalctl -u coverdienst -f

Um Zugriffe zu loggen, muss eine Datei `access.log` angelegt werden, an die angehängt wird.

## Alternative Implementierungen

Die nginx-Konfiguration in der Datei `ws.gbv.de` implementiert einen Dummy-Server, die basierend auf dem Query-Parameter `format` eine JSON-Datei oder eine GIF-Datei (1x1 transparenter Pixel) zurückliefert, d.h. es wird immer eine gültige Antwort aber nie ein Cover zurückgeliefert.

Der `legacy` branch im Repository <https://github.com/gbv/coverdienst> enthält eine ältere Implementierung basierend auf der SeeAlso-API (bis 2022).

