FactoryGirl.define do
  factory :user do
    email 'test@example.org'

    trait :with_avatar do
      avatar { fixture_file_upload(File.expand_path('../../fixtures/files/1.jpg', __FILE__), 'image/jpeg') }
    end
  end
end