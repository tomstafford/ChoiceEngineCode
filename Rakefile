require 'rake/task'
require 'active_record'
require_relative 'lib/choice_engine/spreadsheet_processor.rb'
require_relative 'lib/database_config.rb'

task default: %w[run]

task :run do
  ruby "lib/choice_engine.rb"
end

namespace :db do

  desc "Import"
  task :import do
    DatabaseConfig.make_normal_connection
    sp = ChoiceEngine::SpreadsheetProcessor.new
    ChoiceEngine::SpreadsheetProcessor.reset
    sp.parse
    sp.import_posts
    sp.import_links
  end

  task :annotate do
    annotate
  end

  desc "Migrate the database"
  task :migrate do
    DatabaseConfig.make_normal_connection
    ActiveRecord::MigrationContext.new("db/migrate/").migrate
    Rake::Task["db:schema"].invoke
    puts "Database migrated."
  end

  desc 'Create a db/schema.rb file that is portable against any DB supported by AR'
  task :schema do
    require 'active_record/schema_dumper'
    filename = "db/schema.rb"
    File.open(filename, "w:utf-8") do |file|
      ActiveRecord::SchemaDumper.dump(ActiveRecord::Base.connection, file)
    end
  end
end

namespace :g do
  desc "Generate migration"
  task :migration do
    name = ARGV[1] || raise("Specify name: rake g:migration your_migration")
    timestamp = Time.now.strftime("%Y%m%d%H%M%S")
    path = File.expand_path("../db/migrate/#{timestamp}_#{name}.rb", __FILE__)
    migration_class = name.split("_").map(&:capitalize).join

    File.open(path, 'w') do |file|
      file.write <<-EOF
class #{migration_class} < ActiveRecord::Migration[5.1]
  def change
  end
end
      EOF
    end

    puts "Migration #{path} created"
    abort # needed stop other tasks
  end
end
