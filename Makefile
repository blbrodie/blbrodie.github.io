.PHONY: build serve

deps: .make.deps

clean:
	bundle exec jekyll clean

.make.deps: Gemfile
	bundle
	touch .make.deps

build:
	bundle exec jekyll build --drafts

serve:
	bundle exec jekyll serve --drafts --incremental
