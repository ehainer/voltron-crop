module Voltron
  module Crop
    class Engine < Rails::Engine

      isolate_namespace Voltron

      initializer "voltron.crop.initialize" do
        ::ActionView::Helpers::FormBuilder.send :include, ::Voltron::Crop::Field

        ActiveSupport.on_load :active_record do
          ::ActiveRecord::Base.send :include, ::Voltron::Crop::Base
        end
      end

    end
  end
end
