build:
	jekyll build

develop_docker:
	docker run --rm --volume="$$PWD:/srv/jekyll" -p 4000:4000 -p 35729:35729 -it jekyll/jekyll:4.0 jekyll serve --livereload

build_docker:
	docker run --rm --volume="$$PWD:/srv/jekyll" -it jekyll/jekyll:4.0 jekyll build
