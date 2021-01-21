# FROM image-registry.openshift-image-registry.svc:5000/openshift/time-stack-demo

# # adding source code
# RUN git clone https://github.com/MuhammadYasser2019/time_stack.git

# RUN mv time_stack/.browserslistrc time_stack/.project time_stack/.rspec time_stack/Capfile time_stack/Rakefile time_stack/app/ time_stack/babel.config.js time_stack/bin/ time_stack/bower.json time_stack/config/ time_stack/config.ru time_stack/db/ time_stack/dump.sql#003AZone.Identifier time_stack/features/ time_stack/input.html time_stack/input_2.html time_stack/lib/ time_stack/output.html time_stack/postcss.config.js time_stack/public/ time_stack/shift_migration.rb time_stack/spec/ time_stack/vendor/ time_stack/test/ .

# # fix rails permissions
# RUN chmod -R 0775 /app

# # # run db migrations and run the app and expose the port
# # CMD bin/rails db:migrate RAILS_ENV=development && bundle exec "rackup -P /tmp/rack.pid --host 0.0.0.0 --port 8080"
# CMD bin/rails db:migrate RAILS_ENV=development && bin/rails db:seed && bundle exec "rackup -P /tmp/rack.pid --host 0.0.0.0 --port 8080"

FROM ruby:2.4.1
RUN mkdir -p /app
# WORKDIR /app
# RUN git clone https://github.com/MuhammadYasser2019/time_stack.git
COPY node_modules /app/node_modules
COPY bundle /usr/local/bundle
RUN ls -l
RUN pwd
RUN find / -name TimeStack
RUN find / -name Rakefile
COPY .browserslistrc /app/
COPY TimeStack/.project TimeStack/.rspec TimeStack/Capfile TimeStack/Rakefile TimeStack/app/ TimeStack/babel.config.js TimeStack/bin/ TimeStack/bower.json TimeStack/config/ TimeStack/config.ru TimeStack/db/ TimeStack/dump.sql#003AZone.Identifier TimeStack/features/ TimeStack/input.html TimeStack/input_2.html TimeStack/lib/ TimeStack/output.html TimeStack/postcss.config.js TimeStack/public/ TimeStack/shift_migration.rb TimeStack/spec/ TimeStack/vendor/ TimeStack/test/ TimeStack/Gemfile TimeStack/yarn.lock TimeStack/package.json /app/
RUN chmod -R 0775 /app
CMD bin/rails db:migrate RAILS_ENV=development && bin/rails db:seed && bundle exec "rackup -P /tmp/rack.pid --host 0.0.0.0 --port 8080"