.PHONY: all clean

NAME=Sporx

SOURCE=pod/$(NAME).pod

all: html/$(NAME).html text/$(NAME).text

html/$(NAME).html: $(SOURCE) html
	pod2html $< > $@
	rm pod2htm*.tmp

text/$(NAME).text: $(SOURCE) text
	pod2text $< > $@

html text:
	mkdir -p $@

clean:
	rm -fr html text
