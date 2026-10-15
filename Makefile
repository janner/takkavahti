YAML = takkavahti.yaml
ESP = .venv/bin/esphome

.venv/bin/esphome:
	env -u PYTHONPATH -u PYTHONHOME uv venv .venv
	env -u PYTHONPATH -u PYTHONHOME uv pip install -q --python .venv/bin/python esphome

config: $(ESP)
	$(ESP) config $(YAML)

build: $(ESP)
	$(ESP) compile $(YAML)

# make flash [PORT=/dev/ttyUSB0] — kysyy porttia jos ei anneta
flash: $(ESP)
	$(ESP) run $(YAML) $(if $(PORT),-u $(PORT))

logs: $(ESP)
	$(ESP) logs $(YAML) $(if $(PORT),-u $(PORT))

clean:
	rm -rf .esphome .pio

.PHONY: config build flash logs clean
