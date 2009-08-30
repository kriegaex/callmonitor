.PHONY: configure build clean

build:
	$(MAKE) -C src

configure: .files .language

.files: .features
	./file-list $$(cat .features) > $@

.files-lang: .features
	./file-list $$(cat .features) lang > $@

.language: .language.in .files-lang
	./make-language

clean:
	$(MAKE) -C src clean
