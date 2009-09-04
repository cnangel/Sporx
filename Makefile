.PHONY: all manifest dist doc

ALL_T_HTML:=$(shell ls -1 slides/*.slides | perl -pe 's/slides$$/xul/;s/^.*\///')

all: $(ALL_T_HTML)

manifest: clean
	find . -type f | perl -pe 's/..//' > MANIFEST

dist: doc manifest META.yml
	H=`pwd`; \
	N=`perl -MYAML -e 'print((YAML::LoadFile("META.yml"))->{name})'`; \
	V=`perl -MYAML -e 'print((YAML::LoadFile("META.yml"))->{version})'`; \
	D="$${N}-$${V}"; \
	rm -fr "/tmp/$$D"; \
	cat MANIFEST | cpio -dump "/tmp/$$D"; \
	cd /tmp; tar czvf "$${D}.tar.gz" $$D; rm -r $$D; \
	cd $$H; mv "/tmp/$${D}.tar.gz" ./

doc:
	make -C doc

%.xul: slides/%.slides template/* config.yaml
	rm -f $@
	perl bin/render-template $< $@

clean purge:
	-rm *.xul Sporx-*.tar.gz
