FROM ruby:2.5.1-alpine

ENV DEV_PACKAGES="build-base tzdata g++ musl-dev make nodejs postgresql-dev postgresql-client curl netcat-openbsd bash vim ffmpeg"
RUN apk --update --upgrade add $DEV_PACKAGES \
    && rm /var/cache/apk/*

ENV APP_HOME /usr/src/app

# Create a directory where our app will be placed
RUN mkdir -p $APP_HOME

# Change directory so that our commands run inside this new directory
WORKDIR $APP_HOME

# Copy dependency definitions
ADD Gemfile $APP_HOME/Gemfile
ADD Gemfile.lock $APP_HOME/Gemfile.lock

# Install dependencies
RUN touch ~/.gemrc && echo 'gem: --no-document' >> ~/.gemrc && bundle install

# Get all the code needed to run the app
ADD . $APP_HOME

# Expose port 3000 to the Docker host, so we can access it
# from the outside.
# 1234 is the debug port
EXPOSE 3000 1234

# Configure an entry point, so we don't need to specify
# "bundle exec" for each of our commands.
ENTRYPOINT ["bundle", "exec"]
# Precompile Rails assets
# CMD ["rake", "assets:precompile"]

# The main command to run when the container starts. Also
# tell the Rails dev server to bind to all interfaces by
# default.
CMD ["rails", "server", "-p", "3000", "-b", "0.0.0.0"]
