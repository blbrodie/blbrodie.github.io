.PHONY: build serve

deps: .make.deps

.make.deps: Gemfile
	bundle
	touch .make.deps

build:
	bundle exec jekyll build --drafts

serve:
	bundle exec jekyll serve --drafts --incremental
