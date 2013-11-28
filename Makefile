REPORTER = spec

build:
	@./node_modules/.bin/coffee -b -o lib src/*.coffee

run: build
		@node lib/app.js

test: build
		@NODE_ENV=test ./node_modules/.bin/mocha --compilers coffee:coffee-script \
			--reporter $(REPORTER)

.PHONY: test
