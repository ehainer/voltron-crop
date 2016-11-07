module Voltron
  module Crop
    module Field

      def crop_field(method, options={})
        @method = method
        @options = options.symbolize_keys

        prepare
        file_field "crop_#{method}", @options
      end

      private

        def prepare
          @options[:data] ||= {}
          @options[:data][:crop] = @options.delete(:image) || @object.send(@method).try(:url)
        end

    end
  end
end