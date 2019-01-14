require 'active_record'
require 'active_support'
require 'dotenv'
require 'yaml'
require 'textacular'

Dotenv.load

class DatabaseConfig
  def self.make_normal_connection
    # By default uses ENV['DATABASE_URL']
    ActiveRecord::Base.extend(Textacular)
    ActiveRecord::Base.establish_connection(ENV['DATABASE_URL'])
  end
end
