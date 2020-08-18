develop:
	rm -f Gemfile.lock
	docker run --rm --volume="$$PWD:/srv/jekyll" -p 4000:4000 -p 35729:35729 -it jekyll/jekyll:4.0 bundle exec jekyll serve --livereload --host=0.0.0.0
	rm Gemfile.lock

build:
	rm -f Gemfile.lock
	docker run --rm --volume="$$PWD:/srv/jekyll" -it jekyll/jekyll:4.0 bundle exec jekyll build
	rm Gemfile.lock


