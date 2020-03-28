FROM jekyll/jekyll:4.0


COPY Gemfile .
RUN ["bundle", "install"]

CMD ["bundle", "exec", "jekyll", "serve", "--host=0.0.0.0"]
