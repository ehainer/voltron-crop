require 'mini_magick'

module Voltron
  module Crop
    module Parameters

      def crop!(cropper)
        cropper.params = self.try(:to_unsafe_h) || {}
        cropper.each_crop do |crop|
          from = crop[:image].path

          # Create a temp file to store the newly cropped image
          to = Tempfile.new([crop[:name], File.extname(from)])

          # Crop the image, scale up if it's smaller than the required crop size
          img = MiniMagick::Image.new(from)
          img.crop("#{crop[:w]}x#{crop[:h]}+#{crop[:x]}+#{crop[:y]}")
          if img.width < Voltron.config.crop.min_width || img.height < Voltron.config.crop.min_height
            img.resize "#{Voltron.config.crop.min_width}x#{Voltron.config.crop.min_height}"
          end
          img.write to.path
          to.close

          # Override the tempfile with our newly cropped image tempfile
          crop[:image].tempfile = to

          # Get rid of the crop params, we no longer need them
          exclude = ["x", "y", "w", "h"].map { |i| "#{crop[:name]}_#{i}" }
          self[cropper.resource_name].reject! { |k,v| exclude.include?(k) } 

          # Set the actual attribute param to our "uploaded" file
          self[cropper.resource_name][crop[:name]] = crop[:image]
        end
      end

    end
  end
end
