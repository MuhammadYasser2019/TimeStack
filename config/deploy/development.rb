set :application, "time_stack"
# set :repo_url, "git@github.com:sameersharma25/time_stack.git"

set :user, 'developer'
set :scm, :git
# set :branch, "master"

puts "  *************************************************************"
puts "  *** Deploying to DEVELOPMENT with username #{fetch(:user)} ***"
puts "  *************************************************************"
set :rails_env, 'development'
set :repo_url,"git@github.com:sameersharma25/time_stack.git"
set :branch, "master"
set :use_sudo, false
set :deploy_to, "/home/developer/dev/ts_deploy"
puts "  ******Deploying to #{fetch(:deploy_to)}"
set :keep_releases, 5

# set :domain, '192.168.239.222'
role :web, '104.131.27.11'                          # Your HTTP server, Apache/etc
role :app, '104.131.27.11'                          # This may be the same as your `Web` server
role :db,  '104.131.27.11', :primary => true # This is where Rails migrations will run
#role :db,  "your slave db-server here"

ssh_options: {
        user: 'developer', # overrides user setting above
        keys: %w(/home/developer/.ssh/id_rsa),
        forward_agent: true,
        auth_methods: %w(publickey),
	verbose: :debug
}
#ssh_options[:forward_agent] = true
# default_run_options[:pty] = true

namespace :deploy do
  task :start do ; end
  task :stop do ; end
  task :restart do
  	on roles(:app), :except => { :no_release => true } do
    	run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
  	end
  end
end
