# Takkavahti

ESP32-CAM (AI-Thinker) + KY-026 IR-liekkisensori, ESPhome. Vahtii takkaa kameralla ja liekkisensorilla; kuvavirta näkyy Home Assistantissa tai suoraan selaimessa portissa 8080.

## Kytkentä (KY-026 → ESP32-CAM)

| KY-026 | ESP32-CAM | Huom |
|---|---|---|
| VCC | 3V3 | KY-026 toimii 3,3 V:llä |
| GND | GND | |
| DO | GPIO14 | digitaali (kynnys modulin potentiometrillä) |
| AO | GPIO32 | analogi, ADC1_CH4 |

Vapaat ja käytetyt pinnit on valittu niin, että kamera ja PSRAM säilyvät toimivina (EI GPIO0/2/4/5/12-16/18/19/21-27/33-39). GPIO4:ään (valkoinen LED) voi liittää `light`-komponentin jos haluaa valon mukaan.

## Käyttö

```sh
make config          # validoi YAML
make build           # käännä firmware (.esphome/build/)
make flash PORT=/dev/ttyUSB0   # käännä + lataa
make logs PORT=/dev/ttyUSB0    # sarjaloki
```

`make flash` ilman PORTia esittää porttilistan (kortti pitää olla kiinni tässä koneessa USB-serialilla).

## Ensimmäinen asennus (ESP32-CAM-MB)

1. `git clone https://github.com/janner/takkavahti` omalle koneelle, kopioi `secrets.example.yaml` → `secrets.yaml` ja täytä oikeat arvot.
2. Asenna esphome (`uv` asentuu: `curl -LsSf https://astral.sh/uv/install.sh | sh`) — `make` asentaa esphomen automaattisesti. Windowsilla ilman makea: `uvx esphome run takkavahti.yaml`.
3. Kytke ESP32-CAM moduli ESP32-CAM-MB:ään ja MB USB:llä koneeseen. MB hoitaa download-modin automaattisesti (EI IO0-jumperia eikä erillistä FTDI:tä).
4. `make flash PORT=/dev/ttyUSB0` (vaihda portti; `dmesg | tail` kertoo mikä). Odota "Hard resetting".
5. KY-026 saa jäädä kiinni latauksen ajaksi: sensori on GPIO14/GPIO32 eikä se vaikuta sarjaan/boot-pinneihin. Kiinnitä langat modulin headerien juotospisteisiin pysyvästi (niin ne pysyvät mukana myös MB-dokissa uudelleenfläshäessä) tai irrota latauksen ajaksi. Vaihtoehto siistiin: ruuviliitäntäinen ESP32-CAM-adapterilevy asennuspaikalle.

## Home Assistant

Firmware sisältää ESPHome-API:n, joten mitään "Create Device / Import from file" ei tarvita (ne ovat ESPHome Device Builderin omaisia ja tarvitaan vain jos HA:n pitää hallita YAMLia):

1. Laite liittyy wifiin ja on näkyvissä HA:lle mDNS:llä (`takkavahti.local`).
2. HA: **Settings → Devices & Services → Add Integration → ESPHome** → discovery löytää `takkavahti`-laitteen → **Adopt**. Valmis: entiteetit `Takan kamera`, `Takan liekki`, `Takan IR-signaali`.
3. Päivitykset tulevat tästä repossa: `make flash` päivittyy ensimmäisen sarja-asennuksen jälkeen OTA:n kautta ilman USB:tä. Jätä Device Builderin "Add existing device" väliin, muuten YAML alkaa elää HA:ssa ja repo käy vanhaksi.

Selainvirta ilman HA:ta: `http://takkavahti.local:8080` (stream) tai :8081 (snapshot).

Fallback: jos wifi ei toimi, laite avaa AP:n `takkavahti-fallback` (salasana `secrets.yaml:ssä`), captive portalilla saa wifin asetukset.
