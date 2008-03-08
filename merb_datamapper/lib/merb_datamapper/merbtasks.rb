require 'fileutils'

namespace :dm do
  
  task :merb_start do
    Merb.start :adapter => 'runner',
               :environment => ENV['MERB_ENV'] || 'development'
  end
  
  namespace :db do
    desc "Perform automigration"
    task :automigrate => :merb_start do
      DataMapper::Persistence.auto_migrate!
    end

    desc "Migrate table(s) individually - pass in MODEL=Model1,Model2 to migrate Model1 and Model2"
    task :migrate => :merb_start do
      for model in ENV['MODEL'].split(',')
        begin
          eval(model).auto_migrate!
          puts "Succesfully migrated model #{model}."
        rescue
          puts "!!! Unable to resolve model name #{model} - did you spell your model name correctly?"
        end
      end
    end
  end
  
  namespace :sessions do
    desc "Creates session migration"
    task :create => :merb_start do
      dest = File.join(Merb.root, "schema", "migrations","001_add_sessions_table.rb")
      source = File.join(File.dirname(__FILE__), "merb", "session","001_add_sessions_table.rb")
      #FileUtils.cp source, dest unless File.exists?(dest)
    end
    
    desc "Clears sessions"
    task :clear => :merb_start do
      table_name = ((Merb::Plugins.config[:datamapper] || {})[:session_table_name] || "sessions")
      #Merb::Orms::DataMapper.connect.execute("DELETE FROM #{table_name}")
    end
  end
end