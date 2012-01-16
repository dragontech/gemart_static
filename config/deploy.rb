set :application, "gemart.ro"
set :location, "gemart.ro"
set :repository,  "git@github.com:dragontech/gemart.git"
set :branch, "master"
set :deploy_via, :remote_cache

set :scm, :git
# Or: `accurev`, `bzr`, `cvs`, `darcs`, `git`, `mercurial`, `perforce`, `subversion` or `none`
set :user, "mihai"
set :deploy_to, "/srv/www/#{location}"
set :port, 60000
set :use_sudo, false
default_run_options[:pty] = true

role :web, application                          # Your HTTP server, Apache/etc
role :app, application                          # This may be the same as your `Web` server
role :db,  application, :primary => true        # This is where Rails migrations will run

# Custom tasks for our hosting environment.
namespace :remote do
  desc "Create logs directory."
  task :create_logs_dir, :roles => :app do
    print "    creating #{location} logs directory.\n"
    run "mkdir /srv/www/logs/#{location}"
  end

  desc "Configure Virtual Host"
  task :config_virtual_host do
    virtual_host_config =<<-EOF
      <VirtualHost 178.79.139.120:80>
        ServerAdmin admin@gemart.ro
        ServerName gemart.ro
        ServerAlias www.gemart.ro
        DocumentRoot /srv/www/gemart.ro/current/public_html/
        ErrorLog /srv/www/logs/gemart.ro/error.log     
        CustomLog /srv/www/logs/gemart.ro/access.log combined
      </VirtualHost>
    EOF
    put virtual_host_config, "virtual_host_config"
    sudo "mv virtual_host_config /etc/apache2/sites-available/#{application}"
    sudo "a2ensite #{application}"
    sudo "/etc/init.d/apache2 restart"
  end
end

# Override default tasks which are not relevant to a non-rails app.
namespace :deploy do
  task :migrate do
    puts "    not doing migrate because not a Rails application."
  end
  task :finalize_update do
    puts "    not doing finalize_update because not a Rails application."
  end
  task :start do
    puts "    not doing start because not a Rails application."
  end
  task :stop do 
    puts "    not doing stop because not a Rails application."
  end
  task :restart do
    puts "    not doing restart because not a Rails application."
  end
end

# Callbacks.
before 'deploy:setup', 'remote:create_logs_dir', 'remote:config_virtual_host'
