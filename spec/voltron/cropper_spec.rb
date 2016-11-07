require "rails_helper"

describe Voltron::Cropper do

  let(:user1) { User.new }

  let(:user2) { User.create(avatar: File.open(File.expand_path("../../fixtures/files/1.jpg", __FILE__))) }

  let(:cropper1) { Voltron::Cropper.new(:users) }

  let(:cropper2) { Voltron::Cropper.new(:users, id_param: :custom_id) }

  before(:each) do
    cropper1.params = nil
    cropper2.params = nil
  end

  it "should determine the resource name" do
    expect(cropper1.resource_name).to eq("user")
  end

  it "should have an id in the params" do
    cropper1.params = { "id" => 12345 }
    expect(cropper1.resource_id).to eq(12345)
  end

  it "should find the id given a custom id parameter key" do
    cropper2.params = { "custom_id" => 98765 }
    expect(cropper2.resource_id).to eq(98765)
  end

  it "should have a crop param key for each uploader" do
    expect(cropper1.crop_keys).to eq(["crop_avatar"])
  end

  it "should not have an uploaded file if no file exists on the model" do
    cropper1.params = {}
    expect(cropper1.upload_file(:avatar)).to be(nil)
  end

  it "should create an uploaded file object from a previously uploaded file" do
    cropper1.params = { "id" => user2.id }
    expect(cropper1.upload_file(:avatar)).to be_a(ActionDispatch::Http::UploadedFile)
  end

  it "should yield each set of crop data" do
    cropper1.params = { "id" => user2.id, "user" => { "crop_avatar" => { "x" => 0, "y" => 0, "w" => 100, "h" => 100 } } }
    expect { |b| cropper1.each_crop(&b) }.to yield_with_args(String, Hash)
  end

  it "has a previously uploaded file" do
    cropper1.params = { "id" => user2.id }
    expect(cropper1.current_file(:avatar)).to be_a(CarrierWave::SanitizedFile)
  end

end
