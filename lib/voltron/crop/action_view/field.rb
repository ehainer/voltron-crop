module Voltron
  module Crop
    module Field

      def crop_field(method, options={})
        @method = method
        @options = options.deep_symbolize_keys

        prepare
        file_field method, @options
      end

      private

        def prepare
          @options[:data] ||= {}
          @options[:data].merge!({
            crop_image: @options.delete(:image) || @object.send(@method).try(:url),
            crop_cache: @object.send("#{@method}_cache"),
            crop_x: @object.send("#{@method}_x"),
            crop_y: @object.send("#{@method}_y"),
            crop_zoom: @object.send("#{@method}_zoom")
          })
        end

    end
  end
end