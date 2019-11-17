.PHONY: build serve

deps: .make.deps

clean:
	bundle exec jekyll clean

.make.deps: Gemfile
	bundle
	touch .make.deps

build: deps
	bundle exec jekyll build

serve: deps
	bundle exec jekyll serve --incremental

build-with-drafts: deps
	bundle exec jekyll build --drafts

serve-with-drafs: deps
	bundle exec jekyll serve --drafts --incremental
