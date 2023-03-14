
module Extractor
  module Generators
    class TapGenerator < Rails::Generators::NamedBase
      source_root File.expand_path('templates', __dir__)

      def copy_tap_file
        template "tap.rb.tt", "app/extractors/#{file_name}_tap.rb"
      end
    end
  end
end
