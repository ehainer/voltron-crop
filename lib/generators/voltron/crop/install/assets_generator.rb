module Voltron
  module Crop
    module Generators
      module Install
        class AssetsGenerator < Rails::Generators::Base

          source_root File.expand_path("../../../../templates", __FILE__)

          desc "Install Voltron Crop assets"

          def copy_javascripts_assets
            copy_file "app/assets/javascripts/voltron-crop.js", Rails.root.join("app", "assets", "javascripts", "voltron-crop.js")
            copy_file "app/assets/javascripts/cropit.js", Rails.root.join("app", "assets", "javascripts", "cropit.js")
            copy_file "app/assets/javascripts/simple-slider.js", Rails.root.join("app", "assets", "javascripts", "simple-slider.js")
          end

          def copy_stylesheets_assets
            copy_file "app/assets/stylesheets/voltron-crop.scss", Rails.root.join("app", "assets", "stylesheets", "voltron-crop.scss")
          end

        end
      end
    end
  end
end