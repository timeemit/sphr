set :application, "sphrscap"
set :repository,  "git@github.com:timeemit/sphr.git"
set :deploy_to, "/home/oricksum/public_html/#{application}"

default_run_options[:pty] = true
deploy.task :restart, :roles => :app do
  run "/etc/init.d/apache2 graceful"
end


set :scm, :git
# Or: `accurev`, `bzr`, `cvs`, `darcs`, `git`, `mercurial`, `perforce`, `subversion` or `none`

server '50.57.115.223', :app, :web, :db
# role :web, "50.57.115.223"                          # Your HTTP server, Apache/etc
# role :app, "50.57.115.223"                          # This may be the same as your `Web` server
# role :db,  "50.57.115.223", :primary => true # This is where Rails migrations will run
# role :db,  "your slave db-server here"

set :user, "oricksum"
set :port, 30000

set :scm_username, "timeemit"

# if you're still using the script/reaper helper you will need
# these http://github.com/rails/irs_process_scripts

# If you are using Passenger mod_rails uncomment this:
# namespace :deploy do
#   task :start do ; end
#   task :stop do ; end
#   task :restart, :roles => :app, :except => { :no_release => true } do
#     run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
#   end
# end