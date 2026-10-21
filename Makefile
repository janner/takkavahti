YAML = takkavahti.yaml
VENV_ESP = .venv/bin/esphome
ESP = env -u PYTHONPATH -u PYTHONHOME $(VENV_ESP)

$(VENV_ESP):
	env -u PYTHONPATH -u PYTHONHOME uv venv .venv
	env -u PYTHONPATH -u PYTHONHOME uv pip install -q --python .venv/bin/python esphome
	cp vendor/procfs-sitecustomize.py .venv/lib/python*/site-packages/sitecustomize.py

config: $(VENV_ESP)
	$(ESP) config $(YAML)

build: $(VENV_ESP)
	$(ESP) compile $(YAML)

# make flash [PORT=/dev/ttyUSB0]: prompts for the port if not given
flash: $(VENV_ESP)
	$(ESP) run $(YAML) $(if $(PORT),-u $(PORT))

logs: $(VENV_ESP)
	$(ESP) logs $(YAML) $(if $(PORT),-u $(PORT))

clean:
	rm -rf .esphome .pio

.PHONY: config build flash logs clean