# Dockerfile
# Use ruby image to build our own image
FROM ruby:2.7.2

RUN apt-get update && \
  apt-get install -qq -y --no-install-recommends cron && \
  rm -rf /var/lib/apt/lists/*

# We specify everything will happen within the /app folder inside the container
RUN mkdir /app
WORKDIR /app

# We copy these files from our current application to the /app container
COPY Gemfile Gemfile.lock ./

# We install all the dependencies
RUN bundle install

# We copy all the files from our current application to the /app container
COPY . ./

# We expose the port
EXPOSE 3000

# Start the main process.
CMD ["rails", "server", "-b", "0.0.0.0"]