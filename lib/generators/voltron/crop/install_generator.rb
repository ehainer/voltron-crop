module Voltron
  module Crop
    module Generators
      class InstallGenerator < Rails::Generators::Base

        source_root File.expand_path("../../../templates", __FILE__)

        desc "Add Voltron Crop initializer"

        def inject_initializer

          voltron_initialzer_path = Rails.root.join("config", "initializers", "voltron.rb")

          unless File.exist? voltron_initialzer_path
            unless system("cd #{Rails.root.to_s} && rails generate voltron:install")
              puts "Voltron initializer does not exist. Please ensure you have the 'voltron' gem installed and run `rails g voltron:install` to create it"
              return false
            end
          end

          current_initiailzer = File.read voltron_initialzer_path

          unless current_initiailzer.match(Regexp.new(/# === Voltron Crop Configuration ===/))
            inject_into_file(voltron_initialzer_path, after: "Voltron.setup do |config|\n") do
<<-CONTENT

  # === Voltron Crop Configuration ===

  # The minimum width of the cropped image. If the cropped image width is smaller than this it will be scaled up automatically
  # config.crop.min_width = 300

  # The minimum height of the cropped image. If the cropped image height is smaller than this it will be scaled up automatically
  # config.crop.min_height = 300
CONTENT
            end
          end
        end
      end
    end
  end
end