FROM image-registry.openshift-image-registry.svc:5000/time-stack-4/time-stack24

# adding source code
RUN git clone https://github.com/MuhammadYasser2019/time_stack.git

WORKDIR /app/time_stack

# run bundle and yarn install 
RUN bundle install && yarn install

# fix rails permissions
RUN chmod +x bin/rails

# # run db migrations and run the app and expose the port
CMD bin/rails db:migrate RAILS_ENV=development && bundle exec "rackup -P /tmp/rack.pid --host 0.0.0.0 --port 8080"
