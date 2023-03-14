
module Extractor
  module Generators
    class RequestsGenerator < Rails::Generators::Base
      include ActiveRecord::Generators::Migration
      source_root File.join(__dir__, "templates")

      invoke "active_record:model", ["Request"], migration: false

      def copy_migration
        migration_template "uploads.rb", "db/migrate/create_blazer_uploads.rb", migration_version: migration_version
      end

      def migration_version
        "[#{ActiveRecord::VERSION::MAJOR}.#{ActiveRecord::VERSION::MINOR}]"
      end
    end
  end
end
