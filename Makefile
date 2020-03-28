develop:
	docker run --rm --volume="$$PWD:/srv/jekyll" -p 4000:4000 -it ecen330_website

build:
	docker run --rm --volume="$$PWD:/srv/jekyll" -it ecen330_website bundle exec jekyll build

upload:
