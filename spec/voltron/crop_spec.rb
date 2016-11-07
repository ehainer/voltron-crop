require "rails_helper"

describe Voltron::Crop do

  let(:file) { fixture_file_upload("files/1.jpg", "image/jpeg") }

  let(:controller) { TestsController.new }

  it "has a version number" do
    expect(Voltron::Crop::VERSION).not_to be(nil)
  end

  it "can be croppable" do
    expect(controller.class.respond_to?(:croppable)).to eq(true)
    controller.class.croppable :users
  end

  it "should have a cropper" do
    controller.class.croppable :users
    expect(controller.cropper).to be_a(Voltron::Cropper)
  end

end
