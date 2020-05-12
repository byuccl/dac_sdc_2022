develop: build-image
	docker run --rm --volume="$$PWD:/srv/jekyll" -p 4000:4000 -it website

build: build-image
	docker run --rm --volume="$$PWD:/srv/jekyll" -it website bundle exec jekyll build

build-image:
	docker build -t website .
