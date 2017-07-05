require 'active_record'
require 'active_support'
require 'dotenv'
require 'yaml'
require 'textacular'

Dotenv.load

class DatabaseConfig

  def self.db_config
    environment = ENV.fetch("ENVIRONMENT", "development")

    if ENV['DATABASE_URL']
      config = {}
      config['url'] = ENV['DATABASE_URL'] if ENV['DATABASE_URL']
    else
      config =  YAML::load(File.open('config/database.yml'))
    end

    config['pool'] = ENV['DB_POOL'] || ENV['RAILS_MAX_THREADS'] || 5
    config[environment]
  end

  def self.db_config_admin
    db_config.merge({'database' => 'postgres', 'schema_search_path' => 'public'})
  end

  def self.make_normal_connection
    ActiveRecord::Base.extend(Textacular)
    ActiveRecord::Base.establish_connection(db_config)
  end

  def self.make_admin_connection
    ActiveRecord::Base.establish_connection(db_config_admin)
  end

  def self.create_database
    make_admin_connection
    ActiveRecord::Base.connection.create_database(db_config["database"])
  end

  def self.drop_database
    make_admin_connection
    ActiveRecord::Base.connection.drop_database(db_config["database"])
  end
end