require "rails/generators/active_record"

module Extractor
  module Generators
    class InstallGenerator < Rails::Generators::Base
      include ActiveRecord::Generators::Migration
      source_root File.join(__dir__, "templates")

      def copy_model_file
        template "request.rb.tt", "app/models/request.rb"
      end

      def copy_migration
        migration_template "requests_migration.rb", "db/migrate/create_requests.rb", migration_version: migration_version
      end

      def migration_version
        "[#{ActiveRecord::VERSION::MAJOR}.#{ActiveRecord::VERSION::MINOR}]"
      end
    end
  end
end
