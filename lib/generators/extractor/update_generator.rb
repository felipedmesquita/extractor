require "rails/generators/active_record"

module Extractor
  module Generators
    class UpdateGenerator < Rails::Generators::Base
      include ActiveRecord::Generators::Migration
      source_root File.join(__dir__, "templates")

      def copy_migration
        migration_template "update_requests_migration.rb", "db/migrate/update_requests.rb", migration_version: migration_version
      end

      def migration_version
        "[#{ActiveRecord::VERSION::MAJOR}.#{ActiveRecord::VERSION::MINOR}]"
      end
    end
  end
end
