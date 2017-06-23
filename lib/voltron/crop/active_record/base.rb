module Voltron
  module Crop
    module Base

      extend ActiveSupport::Concern

      module ClassMethods

        def mount_uploader(*args)
          super *args

          column = args.first.to_sym

          attr_accessor "#{column}_x", "#{column}_y", "#{column}_w", "#{column}_h", "#{column}_zoom"

          after_validation do
            upload = send(column)

            if errors.empty? && upload.present?
              # Create a temp file to store the newly cropped image
              to = Tempfile.new([column.to_s, File.extname(upload.path)])

              dimensions = [send("#{column}_w"), send("#{column}_w")].join('x')
              coordinates = [send("#{column}_x"), send("#{column}_y")].join('+')

              # Crop the image, scale up if it's smaller than the required crop size
              img = ::MiniMagick::Image.new(upload.path)
              img.crop("#{dimensions}+#{coordinates}")
              if img.width < Voltron.config.crop.min_width || img.height < Voltron.config.crop.min_height
                img.resize "#{Voltron.config.crop.min_width}x#{Voltron.config.crop.min_height}"
              end
              img.write to.path
              to.close

              input_name = ActionView::Helpers::Tags::Base.new(ActiveModel::Naming.param_key(self), column, nil).send(:tag_name)

              file = ActionDispatch::Http::UploadedFile.new({
                type: upload.content_type,
                filename: upload.file.original_filename,
                head: "Content-Disposition: form-data; name=\"#{input_name}\"; filename=\"#{upload.filename}\"\r\nContent-Type: #{upload.content_type}\r\n",
                tempfile: to
              })

              send("#{column}=", file)

            end
          end
        end
      end
    end
  end
end