require 'tempfile'

module Voltron
  class Cropper

    attr_accessor :resource, :params

    def initialize(resource, options={})
      @resource = resource.to_s.classify.safe_constantize
      @options = options.symbolize_keys
      @options[:id_param] ||= "id"
    end

    # Look for valid crop data in the params, creating a hash of crop data for each valid croppable image
    def each_crop
      params[resource_name] ||= {}
      crop_keys.each do |name|
        if ["#{name}_x", "#{name}_y", "#{name}_w", "#{name}_h"].all? { |k| params[resource_name].key?(k) }
          data = {
            x: params[resource_name]["#{name}_x"],
            y: params[resource_name]["#{name}_y"],
            w: params[resource_name]["#{name}_w"],
            h: params[resource_name]["#{name}_h"],
            image: params[resource_name][name] || upload_file(name),
            name: name
          }

          yield(data) if !data[:image].nil? && File.exists?(data[:image].try(:path))
        end
      end
    end

    def crop_keys
      resource.uploaders.keys.map(&:to_s)
    end

    def resource_name
      resource.name.singularize.underscore
    end

    def resource_id
      params[@options[:id_param].to_s]
    end

    def upload_file(name)
      file = current_file(name)

      if file
        # Write the contents of the currently uploaded file to a new tempfile that will
        # be used in the newly created "Uploaded File"
        tmp = Tempfile.new(name.to_s)
        tmp.write IO.read(file.path)
        tmp.close

        # Create an uploaded file object
        ActionDispatch::Http::UploadedFile.new({
          type: file.content_type,
          filename: file.original_filename,
          head: '',
          tempfile: tmp
        })
      end
    end

    # Get the current file given the attribute name, or nil if model or file does not exist
    def current_file(name)
      begin
        model = resource.find(resource_id)
        model.send(name).try(:file)
      rescue ActiveRecord::RecordNotFound => e
        Voltron.log e, "Crop", :light_red
        e.backtrace.each { |line| Voltron.log line, "Crop", :light_red }
        nil
      end
    end

  end
end
