class User < ApplicationRecord

  mount_uploader :avatar, AvatarUploader

  validates_presence_of :email

end
