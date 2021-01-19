FROM image-registry.openshift-image-registry.svc:5000/openshift/time-stack-24

# adding source code
RUN git clone https://github.com/MuhammadYasser2019/time_stack.git

WORKDIR /app/time_stack

# run bundle and yarn install 
RUN bundle install && yarn install

# fix rails permissions
RUN chmod -R 0775 /app/time_stack
# RUN chmod +x bin/rails

# # run db migrations and run the app and expose the port
# CMD bin/rails db:migrate RAILS_ENV=development && bundle exec "rackup -P /tmp/rack.pid --host 0.0.0.0 --port 8080"
CMD bin/rails db:migrate RAILS_ENV=development && bin/rails db:seed && bundle exec "rackup -P /tmp/rack.pid --host 0.0.0.0 --port 8080"
