namespace :radiant do
  namespace :extensions do
    namespace :polls do
      
      desc "Runs the migration of the Page Attachments extension"
      task :migrate => :environment do
        require 'radiant/extension_migrator'
        if ENV["VERSION"]
          PollsExtension.migrator.migrate(ENV["VERSION"].to_i)
        else
          PollsExtension.migrator.migrate
        end
      end
    
      task :update => :environment do
        FileUtils.cp PollsExtension.root + "/public/stylesheets/polls.css", RAILS_ROOT + "/public/stylesheets/admin"
        FileUtils.cp PollsExtension.root + "/public/javascripts/polls.js", RAILS_ROOT + "/public/javascripts"
      end
    end
  end
end
