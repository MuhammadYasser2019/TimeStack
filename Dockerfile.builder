FROM ruby:2.4.1

# Add NodeJS to sources list
RUN curl -sL https://deb.nodesource.com/setup_10.x | bash -

# Add Yarn to the sources list
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
  && echo 'deb http://dl.yarnpkg.com/debian/ stable main' > /etc/apt/sources.list.d/yarn.list

# Install dependencies
RUN apt-get update -qq && DEBIAN_FRONTEND=noninteractive apt-get -yq dist-upgrade && \
    DEBIAN_FRONTEND=noninteractive apt-get install -yq --no-install-recommends \
    build-essential \
    nodejs \
    yarn && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    truncate -s 0 /var/log/*log

# Create a user and a directory for the app code
RUN mkdir -p /app
RUN useradd -u 1001 -r -g 0 -d /app default
WORKDIR /app
RUN chown -R 1001:0 /app && chmod -R ug+rwx /app 

USER 1001

# Setting env up
ENV RAILS_ENV='development'
ENV NODE_ENV='development'

# Adding gems
ADD Gemfile /app
# COPY Gemfile.lock Gemfile.lock

RUN bundle install 
