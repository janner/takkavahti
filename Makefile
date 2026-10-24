YAML = takkavahti.yaml
VENV_ESP = .venv/bin/esphome
ESP = env -u PYTHONPATH -u PYTHONHOME $(VENV_ESP)

$(VENV_ESP):
	env -u PYTHONPATH -u PYTHONHOME uv venv .venv
	env -u PYTHONPATH -u PYTHONHOME uv pip install -q --python .venv/bin/python esphome
	cp vendor/procfs-sitecustomize.py .venv/lib/python*/site-packages/sitecustomize.py

# ESP-IDF creates its penvs anew on esphome updates; psutil there needs the /proc/stat fix
fix-penv:
	@for d in $$HOME/.cache/esphome/idf/penvs/*/lib/python*/site-packages; do \
	  [ -d "$$d" ] && cp -f vendor/procfs-sitecustomize.py "$$d/sitecustomize.py"; \
	done; true

config: $(VENV_ESP)
	$(ESP) config $(YAML)

build: $(VENV_ESP) fix-penv
	$(ESP) compile $(YAML) || { $(MAKE) -s fix-penv && $(ESP) compile $(YAML); }

# make flash [PORT=/dev/ttyUSB0]: prompts for the port if not given
flash: $(VENV_ESP) fix-penv
	$(ESP) run $(YAML) $(if $(PORT),--device $(PORT)) || { $(MAKE) -s fix-penv && $(ESP) run $(YAML) $(if $(PORT),--device $(PORT)); }

logs: $(VENV_ESP)
	$(ESP) logs $(YAML) $(if $(PORT),--device $(PORT))

clean:
	rm -rf .esphome .pio

.PHONY: config build flash logs clean fix-penv