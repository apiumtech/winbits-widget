.PHONY: build api checkout widget install install_api install_checkout install_widget test test_api test_checkout test_widget watch_api watch_checkout watch_widget

build: api checkout widget
	
api:
	$(MAKE) -C api build
	
checkout:
	$(MAKE) -C checkout build

widget:
	$(MAKE) -C widget build

install: install_api install_checkout install_widget

install_api:
	$(MAKE) -C api install

install_checkout:
	$(MAKE) -C checkout install

install_widget:
	$(MAKE) -C widget install

test: test_api test_checkout test_widget

test_api:
	$(MAKE) -C api test

test_checkout:
	$(MAKE) -C checkout test

test_widget:
	$(MAKE) -C widget test

watch_api:
	$(MAKE) -C api watch

watch_checkout:
	$(MAKE) -C checkout watch

watch_widget:
	$(MAKE) -C widget watch

