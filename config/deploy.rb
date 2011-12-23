set :application, "teaparty"
set :scm,         :git
set :git_shallow_clone, 1
set :repository,  "git@github.com:chiyodarb/teaparty.git"
set :branch,      "master"
set :deploy_via,  :remote_cache
set :deploy_to,   "/mnt/app/#{application}"
set :user,        "app"
set :use_sudo,    false
set :rails_env,   "production"

ssh_options[:keys] = ["#{ENV['HOME']}/.ssh/ec2-s21g.pem"]
ssh_options[:username] = `id -un`.chomp
ssh_options[:forward_agent] = true

host = "gw0.s21g.com"

role :web, host # Your HTTP server, Apache/etc
role :app, host # This may be the same as your `Web` server
role :db,  host, :primary => true # This is where Rails migrations will run

# if you're still using the script/reaper helper you will need
# these http://github.com/rails/irs_process_scripts

load 'deploy/assets'

after "deploy:update_code", "deploy:assets:precompile"

# If you are using Passenger mod_rails uncomment this:
namespace :deploy do
  task :bundle do
    target = "public/system/bundle"
    run "cd #{deploy_to}/#{current_dir}; bundle install --path #{target}"
  end

  task :start do
    cd_to = "cd #{deploy_to}/#{current_dir}"
    run "#{cd_to}; bundle exec unicorn -c unicorn.conf.rb -E production -D"
  end

  task :restart, :roles => :app, :except => { :no_release => true } do
    get_pid = "/usr/bin/env ruby /mnt/unicorn_master.rb 3050"
    run "kill -USR2 `#{get_pid}`"
    run "kill -QUIT `#{get_pid}`"
  end

  task :after_symlink do
    run "ln -s #{deploy_to}/shared/config/database.yml #{release_path}/config/database.yml"                                                          
  end 
end
