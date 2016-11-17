require 'voltron'
require 'carrierwave'
require 'voltron/config/crop'
require 'voltron/cropper'
require 'voltron/crop/version'
require 'voltron/crop/action_view/field'
require 'voltron/crop/action_controller/parameters'

module Voltron
  module Crop

    def croppable(resource = nil, options={})
      include ControllerMethods

      resource ||= controller_name
      @cropper ||= Voltron::Cropper.new(resource, options)

      before_action :crop_image
    end

    module ControllerMethods

      def crop_image
        params.crop!(cropper) if params[cropper.resource_name.to_sym]
      end

      def cropper
        self.class.instance_variable_get("@cropper")
      end

    end

  end
end

require 'voltron/crop/engine' if defined?(Rails)