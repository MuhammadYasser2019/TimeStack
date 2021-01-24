FROM image-registry.openshift-image-registry.svc:5000/openshift/ruby:2.4.1

RUN mkdir /app

# # adding source code
COPY . /app/
RUN rm -rf /app/bundle

####### add bundle from builder image ########
COPY bundle /usr/local/bundle

WORKDIR /app

# # fix rails permissions
RUN chmod -R 0775 /app

# # # run db migrations and run the app and expose the port
# # CMD bin/rails db:migrate RAILS_ENV=development && bundle exec "rackup -P /tmp/rack.pid --host 0.0.0.0 --port 8080"
# CMD bin/rails db:migrate RAILS_ENV=$RAILS_ENV && bin/rails db:seed && bundle exec "rackup -P /tmp/rack.pid --host 0.0.0.0 --port 8080"
CMD bundle exec "rackup -P /tmp/rack.pid --host 0.0.0.0 --port 8080"

