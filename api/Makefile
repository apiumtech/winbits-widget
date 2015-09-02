.PHONY: build watch public install packages test clean

bower=./node_modules/.bin/bower
jake=./node_modules/.bin/jake
brunch=./node_modules/.bin/brunch

build: public
	$(brunch) build;

public:
	$(jake) "switch-config[dev]"; \
	rm -rf public;

watch: public
	$(brunch) watch;

install: packages build

packages:
	npm install; \
	$(bower) install --allow-root;

test:
	@echo "No tests for API..."

clean:
	rm -fr build components template.js

