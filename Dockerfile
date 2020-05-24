FROM ruby:2.6

COPY Gemfile Gemfile.lock pull-request.sh pull-request.rb ./
RUN bundle install
RUN chmod +x /pull-request.sh

ENTRYPOINT ["/pull-request.sh"]