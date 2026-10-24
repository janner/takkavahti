# Takkavahti

Takkavahti is a Finnish word. *Takka* means fireplace and *vahti* means guard or watch, so the name means **fireplace guard**: a device that watches a fireplace.

ESP32-CAM (AI-Thinker) plus a KY-026 flame sensor, running ESPHome. It streams video to Home Assistant or straight to a browser on port 8080.

## Wiring (KY-026 to ESP32-CAM)

Annotated diagram: `docs/kytkenta-annotated.png`. The labels inside the image are in Finnish. The same information is in the table below.

| KY-026 | ESP32-CAM | Notes |
|---|---|---|
| VCC | 3.3V | KY-026 runs at 3.3 V. **NOT 5V!** |
| GND | GND | |
| DO | GPIO14 | digital output, threshold set with the module's potentiometer |
| AO | not connected | GPIO32 is not on the module header, and ADC2 pins cannot be read while WiFi is on |

Free pins on this module: GPIO12/13/14/15/2/4 (SD lines, usable when there is no SD card; GPIO4 is the white LED, GPIO2/12/15 are strapping pins). GPIO16 belongs to PSRAM, GPIO0 is the camera XCLK, GPIO1/3 are serial. Leave those alone. GPIO32/33 are not on the header at all (33 is the red LED internally).

## Usage

```sh
make config          # validate the YAML
make build           # compile firmware (.esphome/build/)
make flash PORT=/dev/ttyUSB0   # compile + upload
make logs PORT=/dev/ttyUSB0    # serial log
```

`make flash` without PORT shows a list of ports. The card must be plugged into this machine over USB serial.

## First install (ESP32-CAM-MB)

1. `git clone https://github.com/janner/takkavahti`, copy `secrets.example.yaml` to `secrets.yaml` and fill in the real values.
2. Install esphome. `uv` handles it: `curl -LsSf https://astral.sh/uv/install.sh | sh`. `make` installs esphome automatically. On Windows without make: `uvx esphome run takkavahti.yaml`.
3. Plug the ESP32-CAM module into the ESP32-CAM-MB board and connect the MB to the computer with USB. The MB handles download mode by itself. No IO0 jumper, no separate FTDI.
4. `make flash PORT=/dev/ttyUSB0`. Change the port if needed, `dmesg | tail` tells which one. Wait for "Hard resetting".
5. The KY-026 can stay connected while flashing. The sensor sits on GPIO14 and does not affect serial or boot pins. Solder the wires to the module header pads permanently, so they survive re-flashing in the MB dock, or detach them while flashing. A screw terminal ESP32-CAM adapter board is a neat alternative for a fixed install.

## Home Assistant

The firmware includes the ESPHome API, so no "Create Device / Import from file" step is needed. Those belong to the ESPHome Device Builder and only matter if HA should manage the YAML.

1. The device joins the wifi and shows up in HA over mDNS (`takkavahti.local`).
2. In HA: **Settings -> Devices & Services -> Add Integration -> ESPHome**. Discovery finds the `takkavahti` device. Click **Adopt**. Done. The names stay Finnish so existing entities keep working:
   `Takan kamera`, `Takan liekki`, `Takan valaisin` (flash LED, GPIO4), `Uudelleenkäynnistys` (restart button), `Unitila` (sleep button), `Yhteys` (API status), `WiFi-signaali`, `Käyttöaika`, `Firmware-versio`, `IP-osoite`.
3. Sleep mode: pressing **Unitila** puts the ESP32 into deep sleep. It wakes when the flame sensor sees a flame (GPIO14 HIGH), reboots and reconnects. It refuses to sleep while the flame is on. The red status LED blinks when there is no wifi/API connection.
4. Updates come from this repo. After the first serial install, `make flash` updates over the air without USB. Skip "Add existing device" in Device Builder. Otherwise the YAML starts living in HA and the repo goes stale.

Browser stream without HA: `http://takkavahti.local:8080` (stream) or `:8081` (snapshot).

Fallback: if the wifi fails, the device opens an AP called `takkavahti-fallback`. The password is in `secrets.yaml`. The captive portal lets you set the wifi.
