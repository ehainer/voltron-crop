require 'tempfile'
require 'mini_magick'

module Voltron
  module Crop
    module Parameters

      def crop!(cropper)
        if @parameters[cropper.resource_name]
          cropper.params = @parameters
          cropper.each_crop do |k,crop|
            from = crop[:image].path

            begin
              # Create a temp file to store the newly cropped image
              to = Tempfile.new([crop[:name], File.extname(from)])

              # Crop the image, scale up if it's smaller than the required crop size
              img = MiniMagick::Image.new(from)
              img.combine_options do |c|
                c.crop("#{crop[:w]}x#{crop[:h]}+#{crop[:x]}+#{crop[:y]}")
                if img.width < Voltron.config.crop.min_width || img.height < Voltron.config.crop.min_height
                  c.resize "#{Voltron.config.crop.min_width}x#{Voltron.config.crop.min_height}"
                end
                c.repage.+
              end
              img.write to.path
              to.close

              # Override the tempfile with our newly cropped image tempfile
              crop[:image].tempfile = to

              # Get rid of the crop params, we no longer need them
              @parameters[cropper.resource_name].delete(k)

              # Set the actual attribute param to our "uploaded" file
              @parameters[cropper.resource_name][crop[:name]] = crop[:image]
            rescue => e
              if Voltron.config.crop.raise_on_error
                raise e
              else
                Voltron.log e, "Crop", :light_red
                e.backtrace.each { |line| Voltron.log line, "Crop", :light_red }
              end
            end
          end
        end
      end

    end
  end
end
