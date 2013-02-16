
build: compile components index.js
	@component build --dev

components: component.json
	@component install --dev

compile:
	@coffee --compile --output lib src 

clean:
	rm -fr build components template.js

test: build
	@open test/tests.html

.PHONY: clean test components