module Voltron
  module Crop
    class Engine < Rails::Engine

      isolate_namespace Voltron

      initializer "voltron.crop.initialize" do
        ::ActionController::Parameters.send :prepend, ::Voltron::Crop::Parameters
        ::ActionView::Helpers::FormBuilder.send :include, ::Voltron::Crop::Field
        ::ActionController::Base.send :extend, ::Voltron::Crop
      end

    end
  end
end
