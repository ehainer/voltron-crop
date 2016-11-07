class AvatarUploader < CarrierWave::Uploader::Base

  include CarrierWave::MiniMagick

  storage :file

  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  def default_url
    ActionController::Base.helpers.asset_path([version_name, "default.png"].compact.join('_'))
  end

  version :thumb do
    process resize_to_fit: [50, 50]
  end

end
