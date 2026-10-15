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

## Ensimmäinen asennus

1. Täytä `secrets.yaml`.
2. Kytke FTDI-adapteri 3.3 V:llä: TX→RX, RX→TX, GND→GND, 3V3→3V3. **EI 5V** — polttaa modulin.
3. Bootloader-tila: IO0→GND ennen resettiä, irrota latauksen jälkeen.
4. `make flash PORT=/dev/ttyUSB0`, odota "Hard resetting", nosta raja.
5. Laite liittyy wifiin nimellä `takkavahti`; selaimessa `http://takkavahti.local:8080` (stream) tai portti 8081 (snapshot). Home Assistant löytää sen mDNS:llä (API).

Fallback: jos wifi ei toimi, laite avaa AP:n `takkavahti-fallback` (salasana `secrets.yaml:ssä`), captive portalilla saa wifin asetukset.
