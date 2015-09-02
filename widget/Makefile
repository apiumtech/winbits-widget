.PHONY: build watch public install packages test clean

bower=./node_modules/.bin/bower
jake=./node_modules/.bin/jake
brunch=./node_modules/.bin/brunch
mocha-phantomjs=./node_modules/.bin/mocha-phantomjs

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
	$(mocha-phantomjs) -R spec http://dev.mylooq.com/test/\?grep\=${grep}

clean:
	rm -fr build components template.js

