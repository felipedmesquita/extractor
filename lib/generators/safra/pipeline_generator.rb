
module Extractor
  module Generators
    class PipelineGenerator < Rails::Generators::NamedBase
      source_root File.expand_path('templates', __dir__)

      def copy_cleaned_file
        template "pipeline/cleaned.sql.tt", "app/sql/#{file_name}/#{file_name}_cleaned.sql"
      end

      def copy_deduplicated_file
        template "pipeline/deduplicated.sql.tt", "app/sql/#{file_name}/#{file_name}_cleaned_deduplicated.sql"
      end

      def copy_model_file
        template "pipeline/model.sql.tt", "app/sql/#{file_name}/#{file_name}_model.sql"
      end
    end
  end
end
