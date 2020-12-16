build:
	jekyll build

serve:
	jekyll serve

deploy:
	jekyll build
	ssh byu-domains "rm -rf public_html/courses/ecen625_new/*"
	scp -r _site/* byu-domains:public_html/courses/ecen625_new/

develop_docker:
	docker run --rm --volume="$$PWD:/srv/jekyll" -p 4000:4000 -p 35729:35729 -it jekyll/jekyll:4.0 jekyll serve --livereload

build_docker:
	docker run --rm --volume="$$PWD:/srv/jekyll" -it jekyll/jekyll:4.0 jekyll build
