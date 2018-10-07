.PHONY: build serve

build:
	bundle exec jekyll build --drafts

serve:
	bundle exec jekyll serve --drafts --incremental
